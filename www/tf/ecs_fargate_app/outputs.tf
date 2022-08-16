# The load balancer DNS name


output "ecr_repo" {
    value = aws_ecr_repository.ecr_repo.name
}