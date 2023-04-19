terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

# resource "aws_instance" "app_server" {
#   ami           = "ami-0103f211a154d64a6"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }
