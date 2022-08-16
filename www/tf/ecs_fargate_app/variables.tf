
variable "environment" {
  description = "Environment"
  type        = string
}

variable "app" {

  description = "The name of the app"
  type        = string
}

variable "app_service" {
  type = string
  description = "The service of the corresping app. e.g. api, ml_api"
}


variable "region" {

  description = "the AWS region"
  type        = string
}


variable "container_port" {
  type = number
}


# API route
variable "api_domain" {
  type = string
}

variable "route53_hosted_zone" {

  description = "The hosted zone for lookup and added the www domain"
}


variable "api_cert_arn" {

  description = "the Cert to use, must always be for var.region"
}


variable "ecr_image" {
  type        = string
  description = "API Task ECR Image"
}


variable "waf_name" {
  type = string
}

variable "target_health_check_path" {
  type = string
}
variable "security_group_name" {
  type = string
}