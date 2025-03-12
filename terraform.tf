terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "quiavi"
    # workspaces {
    #   name = "tf-aws-overview-dev"
    # }
    workspaces {
      # tags = ["repo:tf-aws-overview"]
      tags = {
        repo = "tf-aws-overview"
      }
    }
  #   workspaces {
  #     tags = ["megauniquekey"]
  #   }
  # }
}
}
