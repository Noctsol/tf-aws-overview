/*
    Deploying EC2 instances
*/

# Public key that I'm going to use for all the instances
resource "aws_key_pair" "root" {
  key_name   = "admin-ec2-key"
  public_key = file("local_ref/ec2key.pub")
}

##### VM 1 #####


# resource "aws_network_interface" "root" {
#   subnet_id       = aws_subnet.rootwest.id
#   security_groups = [aws_security_group.root.id]
#   tags = {
#     Name = "nic-uw2-prod-default"
#   }
# }

# resource "aws_eip" "root" {
#   network_interface = aws_network_interface.root.id
#   tags = {
#     Name = "pip-uw2-prod-default"
#   }
# }

# resource "aws_instance" "root" {
#   ami           = "ami-00c257e12d6828491"
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.root.key_name
#   network_interface {
#     network_interface_id = aws_network_interface.root.id
#     device_index         = 0
#   }
#   tags = {
#     Name = "ec2-uw2-dev-default"
#   }
# }


##### VM 2 #####

# # Deploying on different account
# # terraform state show aws_key_pair.acct1west2
# resource "aws_key_pair" "acct1west2" {
#   provider   = aws.acct1west2
#   key_name   = "admin-ec2-key"
#   public_key = file("local_ref/ec2key.pub")
# }


# resource "aws_network_interface" "acct1west2" {
#   provider  = aws.acct1west2
#   subnet_id = aws_subnet.acct1west2.id
#   tags = {
#     Name = "nic-uw2-prod-acct1west2"
#   }
# }

# resource "aws_instance" "acct1west2" {
#   provider        = aws.acct1west2
#   ami             = "ami-00c257e12d6828491"
#   instance_type   = "t2.micro"
#   key_name        = aws_key_pair.acct1west2.key_name
#   security_groups = [aws_security_group.acct1west2.name]
#   network_interface {
#     network_interface_id = aws_network_interface.acct1west2.id
#     device_index         = 0
#   }

#   tags = {
#     Name = "ec2-uw2-dev-default"
#   }
# }

# output "ec2" {
#   value = {
#     root = {
#       id         = aws_instance.root.id
#       public_ip  = aws_instance.root.public_ip
#       private_ip = aws_instance.root.private_ip
#     }
#     acct1west2 = {
#       id         = aws_instance.acct1west2.id
#       public_ip  = aws_instance.acct1west2.public_ip
#       private_ip = aws_instance.acct1west2.private_ip
#     }
#   }

# }
