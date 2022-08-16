
variable "environment" {
  type    = string
  default = "tf_dev"
}

variable "app" {
  type    = string
  default = "compiler_gym"
}

# Compiler_gym_api
module "compiler_gym_api" {
  source                   = "../ecs_fargate_app/"
  environment              = var.environment
  app                      = var.app
  app_service              = "api"
  region                   = "us-west-1"
  container_port           = 5000
  api_domain               = "compilergym-api.qa.metademolab.com"
  route53_hosted_zone      = "qa.metademolab.com"
  api_cert_arn             = "arn:aws:acm:us-west-1:790537050551:certificate/c03e082f-741a-400f-8559-8d27ef2307fc"
  ecr_image                = "qa_compiler_gym_api_repo"
  waf_name                 = ""
  target_health_check_path = "/"
#  security_group_name  = "dev-admin-allow-fb-corp-only"
 security_group_name  = "admin-fb-corp-only"
}


# Shared model zoo image
module "compiler_gym_www" {
  source              = "../s3_www_app/"
  environment         = var.environment
  app                 = var.app
  app_service         = "www"
  www_cert_arn        = "arn:aws:acm:us-east-1:790537050551:certificate/dd50e59c-964c-4a47-b792-11281bf3861a"
  www_domain          = "compilergym.qa.metademolab.com"
  route53_hosted_zone = "qa.metademolab.com"
  www_waf_acl_arn     = ""
}