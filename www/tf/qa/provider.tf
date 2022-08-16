terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"

    }
  }

}

provider "aws" {
  region = "us-west-1"
  default_tags {
    tags = {
      env    = "tf_dev"
      demo   = "shared"
      oncall = "ai-playground"
    }
  }
}