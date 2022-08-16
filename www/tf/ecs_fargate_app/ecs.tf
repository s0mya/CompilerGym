


###################################
#  ECS adds an https listener to the load balancer
###################################
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS" # Only allow HTTPS connections
  certificate_arn = var.api_cert_arn

  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }

    # TODO sometimes terraform gets stuck deleting dependent reseources.
  # Inviestigate the following workaround as per https://github.com/hashicorp/terraform/issues/16065#issuecomment-328648133

  # lifecycle {
  #   replace_on_change = {
  #     target_group_id = "${aws_lb_target_group.service.id}"
  #   }
  # }
}

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
#  ECS Logs
###################################
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/${var.environment}/${var.app}/${var.app_service}/ecs"
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
  name = "${var.environment}-${var.app}-${var.app_service}-ecs-task-role"

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
# ECS Task Definition
###################################
resource "aws_ecs_task_definition" "compilergym_api_ecs_task_definition" {
  family                   = "${var.environment}-${var.app}-api-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn


  container_definitions = jsonencode([
    {
      "name"      = "${var.environment}-${var.app}-api-container"
      "image"     = "${aws_ecr_repository.ecr_repo.repository_url}:latest"
      "essential" = true
      "portMappings" = [
        {
          "containerPort" = var.container_port # docker port
          "hostPort"      = var.container_port   
        }
      ]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : "${var.region}",
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_log_group.id}",
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
    security_groups  = [data.aws_security_group.default.id, data.aws_security_group.admin-fb-corp.id]
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.id
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

###################################
#  ECS Instance Target Group
###################################
resource "aws_lb_target_group" "target_group" {
  name        = replace("${var.environment}-${var.app}-tg", "_", "-") # only alphanumeric characters and hyphens allowed in "name"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default.id
  target_type = "ip"


  health_check {
    healthy_threshold   = "2"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "120"
    unhealthy_threshold = "2"
    path                = var.target_health_check_path
  }

  lifecycle {
    create_before_destroy = true
  }
}


###################################
#  ALB Listenter Rule for the model.
###################################
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/predictions/detr_*"]
    }
  }
}



###################################
#  ECR REPO for the container image
###################################
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.ecr_image}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  
}

###################################
#  ECR Repo lifecycle policy
###################################
resource "aws_ecr_lifecycle_policy" "lifecycle_polcy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}
