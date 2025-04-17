/*

Deploying VPCs everywhere
Ideally, should have 50k+ IPs in each VPC
# Some network addresses
10.0.0.0/17
10.0.128.0/17
10.1.0.0/17
10.1.128.0/17
*/

locals {
  classA_cidr = "10.0.0.0/8"
  classB_cidr = "172.16.0.0/12"
  classC_cidr = "192.168.0.0/16"
}

###### CREATING VPCS ######
# Virtual private cloud and their subnets
resource "aws_vpc" "rootwest" {
  cidr_block = "10.0.0.0/17"
  tags = {
    Name = "vpcrootwest"
    env  = "dev"
  }
}
resource "aws_subnet" "rootwest" {
  vpc_id     = aws_vpc.rootwest.id
  cidr_block = "10.0.0.0/22"
  availability_zone = "us-west-2a"
  tags = {
    Name = "subnetrootwestdefault"
    env  = "dev"
  }
}
resource "aws_route_table_association" "rootwest" {
  subnet_id      = aws_subnet.rootwest.id
  route_table_id = aws_route_table.rootwest.id
}
resource "aws_route_table" "rootwest" {
  vpc_id = aws_vpc.rootwest.id
  tags = {
    Name = "routetablerootwest"
    env  = "dev"
  }
}
resource "aws_security_group" "rootwest" {
  name        = "uw2-prod-default"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.rootwest.id
  # Allow ALL inbound traffic from your public IP
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.mypublicip]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.classA_cidr, # Class A
      local.classB_cidr, # Class B
      local.classC_cidr  # Class C
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_vpc" "acct1west2" {
  provider   = aws.acct1west2
  cidr_block = "10.0.128.0/17"
  tags = {
    Name = "vpcacct1west2"
    env  = "dev"
  }
}
resource "aws_route_table" "acct1west2" {
  provider = aws.acct1west2
  vpc_id   = aws_vpc.acct1west2.id
  tags = {
    Name = "routetableacct1west2"
    env  = "dev"
  }
}

resource "aws_route_table_association" "acct1west2" {
  provider       = aws.acct1west2
  subnet_id      = aws_subnet.acct1west2.id
  route_table_id = aws_route_table.acct1west2.id
}
resource "aws_subnet" "acct1west2" {
  provider   = aws.acct1west2
  vpc_id     = aws_vpc.acct1west2.id
  cidr_block = "10.0.128.0/22"
  tags = {
    Name = "subnetacct1west2default"
    env  = "dev"
  }
}
resource "aws_security_group" "acct1west2" {
  provider    = aws.acct1west2
  name        = "uw2-prod-default"
  description = "Allow HTTP and SSH inbound traffic"
 vpc_id      = aws_vpc.acct1west2.id
  # Allow ALL inbound traffic from your public IP
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.mypublicip]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.classA_cidr, # Class A
      local.classB_cidr, # Class B
      local.classC_cidr  # Class C
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# To attach public IPs, you need to create an Internet Gateway and set it up
# EVEN if you are routing through a TGW NAT Gateway
resource "aws_internet_gateway" "acct1west2_igw" {
  provider = aws.acct1west2
  vpc_id   = aws_vpc.acct1west2.id
  tags = {
    Name = "acct1west2-IGW"
  }
}

resource "aws_subnet" "publicsubnet" {
  provider   = aws.acct1west2
  vpc_id     = aws_vpc.acct1west2.id
  cidr_block = "10.0.132.0/22"
  tags = {
    Name = "acct1west2-public-subnet"
  }

}

resource "aws_route_table" "acct1west2_public_rt" {
  provider = aws.acct1west2
  vpc_id   = aws_vpc.acct1west2.id
  tags = {
    Name = "acct1west2-public-route-table"
  }
}
resource "aws_route" "acct1west2_public_to_igw" {
  provider               = aws.acct1west2
  route_table_id         = aws_route_table.acct1west2_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.acct1west2_igw.id
}
resource "aws_route_table_association" "acct1west2_public_assoc" {
  provider       = aws.acct1west2
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.acct1west2_public_rt.id
}






# Creates VPC and Route Table
module "vpc_acct2west2" {
  source     = "./vpc"
  vpc_name   = "acct2west2"
  cidr_block = "10.1.0.0/17"
  tags = {
    Environment = "dev"
  }
  providers = {
    aws = aws.acct2west2
  }
}
resource "aws_subnet" "acct2west2" {
  provider   = aws.acct2west2
  vpc_id     = module.vpc_acct2west2.vpc_id
  cidr_block = "10.1.0.0/22"
  tags = {
    Name        = "subnetacct2west2default"
    Environment = "dev"
  }
}
resource "aws_route_table_association" "acct2west2" {
  provider       = aws.acct2west2
  subnet_id      = aws_subnet.acct2west2.id
  route_table_id = module.vpc_acct2west2.route_table_id
}

resource "aws_security_group" "acct2west2" {
  provider    = aws.acct2west2
  name        = "uw2-prod-default"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = module.vpc_acct2west2.vpc_id
  # Allow ALL inbound traffic from your public IP
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.mypublicip]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.classA_cidr, # Class A
      local.classB_cidr, # Class B
      local.classC_cidr  # Class C
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





