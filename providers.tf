provider "aws" {
  region  = var.aws_region

  default_tags {
    tags = {
      Name = local.stack_name
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "useast1"

  default_tags {
    tags = {
      Name = local.stack_name
    }
  }
}

terraform {
  backend "s3" {
    key                  = "main.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "workspaces"
    dynamodb_table       = "terraform_locks"
  }

  required_providers {
    aws = {
      version = "~> 3.47"
      configuration_aliases = [ aws.useast1 ]
    }
  }

}