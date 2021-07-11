terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.47"
      configuration_aliases = [aws.useast1]
    }
  }
}
