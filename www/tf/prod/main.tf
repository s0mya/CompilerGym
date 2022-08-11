
variable "environment" {
  default     = "prod"
  description = "Environment"
  type        = string
}

variable "app" {
  default     = "compilergym"
  description = "The name of the app"
  type        = string
}


variable "account_id" {
  default     = "223420189915"
  description = "the AWS Account ID"
  type        = string
}


variable "region" {
  default     = "us-east-2"
  description = "the AWS region"
  type        = string
}


variable "container_port" {
  default = 5000
  type    = number
}

# The port the load balancer will listen on
variable "api_lb_port" {
  default = "443"
}

# The load balancer protocol
variable "api_lb_protocol" {
  default = "HTTPS"
}

# WWW route
variable "www_domain" {
  default = "compilergym.metademolab.com"
}
# API route
variable "api_domain" {
  default = "compilergym-api.metademolab.com"
}

variable "route53_hosted_zone" {
  default     = "metademolab.com"
  description = "The hosted zone for lookup and added the www domain"
}

variable "www_cert_arn" {
  default     = "arn:aws:acm:us-east-1:223420189915:certificate/1009bfac-ea5e-470a-8da5-6c43ed10f886"
  description = "the Cert to use. **NOTE** must always be us-east-1"
}

variable "api_cert_arn" {
  default     = "arn:aws:acm:us-east-2:223420189915:certificate/9b903151-19b2-4702-aa30-3cf94c18b9a1"
  description = "the Cert to use, **NOTE** must always be for var.region"
}

variable "waf_public_facing" {
  default     = false
  type        = bool
  description = "If the WAF (firewall) can be public facing."
}


module "compilergym_app_prod" {
  source = "../base_compilergym_app"


  environment         = var.environment
  app                 = var.app
  account_id          = var.account_id
  region              = var.region
  container_port      = var.container_port
  api_lb_port         = var.api_lb_port
  api_lb_protocol     = var.api_lb_protocol
  www_domain          = var.www_domain
  api_domain          = var.api_domain
  route53_hosted_zone = var.route53_hosted_zone
  www_cert_arn        = var.www_cert_arn
  api_cert_arn        = var.api_cert_arn
  waf_public_facing   = var.waf_public_facing
  ecr_image           = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/compilergym_demo_api:prod_latest"
}
