terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # TODO: https://github.com/cloudposse/terraform-aws-ecs-cluster/issues/65
      version = ">= 5.0.0, < 6.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
  }
  required_version = ">= 1.3"
}
