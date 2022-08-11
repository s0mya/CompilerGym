
###################################
#  ECS Cluster
###################################
resource "aws_ecs_cluster" "compilergym_api_ecs_cluster" {
  name = "${var.environment}-${var.app}-api-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


###################################
# LOG Group for ECS Task
###################################
resource "aws_cloudwatch_log_group" "compilergym_api_log_group" {
  name = "/ecs/${var.environment}-${var.app}-api-task"
}


###################################
#  ECS Task Execution Role
###################################
# data "aws_iam_role" "ecs_task_execution_role" {
#   name = "ecsTaskExecutionRole"
# }
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.app}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

###################################
#  ECS Task  Role
###################################
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-${var.app}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}



###################################
# ECS Task
###################################
resource "aws_ecs_task_definition" "compilergym_api_ecs_task_definition" {
  family                   = "${var.environment}-${var.app}-api-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  #   execution_role_arn       = var.task_execution_role_arn
  #   task_role_arn            = var.task_role_arn


  container_definitions = jsonencode([
    {
      "name"      = "${var.environment}-${var.app}-api-container"
      "image"     = var.ecr_image
      "essential" = true
      "portMappings" = [
        {
          "containerPort" = 5000
          "hostPort"      = 5000
        }
      ]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : "${var.region}",
          "awslogs-group" : "${aws_cloudwatch_log_group.compilergym_api_log_group.id}",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "${var.environment}-${var.app}-api-logs"
        }
      }
    }
  ])
}


###################################
# ECS Service
###################################
resource "aws_ecs_service" "compilergym_api_ecs_service" {
  name            = "${var.environment}-${var.app}-api-ecs-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.compilergym_api_ecs_cluster.id
  task_definition = aws_ecs_task_definition.compilergym_api_ecs_task_definition.arn
  desired_count   = 1
  #   desired_count                      = var.desired_count
  #   deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  #   force_new_deployment = true

  network_configuration {
    security_groups  = [aws_security_group.nsg_task.id]
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "${var.environment}-${var.app}-api-container"
    container_port   = var.container_port
  }

  lifecycle {
    # Ignore changes in desired count in future TF deployemnts
    # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#ignoring-changes-to-desired-count
    ignore_changes = [desired_count, task_definition]
    // TODO Add this once stabilized
    # ignore_changes = [task_definition]
  }

}
