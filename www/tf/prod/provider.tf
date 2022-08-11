###################################
# Terraform - Required Providers
###################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

###################################
# AWS Provider
###################################
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env    = var.environment
      demo   = var.app
      oncall = "ai-playground"
    }
  }
}


###################################
# Terraform Backend Config
###################################
terraform {
  backend "s3" {
    bucket         = "admin-223420189915-tf-remote-state"
    key            = "prod/compilergym/terraform.tfstate" # TODO update this for each project
    region         = "us-east-1"
    dynamodb_table = "admin_tf_remote_state_locking"
    encrypt        = true
  }
}
