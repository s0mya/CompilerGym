output "www_cloudfront_id" {
    value = module.compiler_gym_www.www_cloudfront_id
}

output "www_bucket" {
    value = module.compiler_gym_www.www_bucket
}


output "ecr_repo" {
    value = module.compiler_gym_api.ecr_repo
}
