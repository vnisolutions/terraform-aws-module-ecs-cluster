resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.cluster_name}-${var.service_name}"
  retention_in_days = var.retention_in_days
  tags = {
    Name        = "${var.cluster_name}-${var.service_name}"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

#--- Fargate SG  ---
resource "aws_security_group" "sg_fargate" {
  name        = "${var.cluster_name}-${var.service_name}-sg"
  description = "Allow ALB to access ECS tasks"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Allow from ALB"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = var.cidr_ingress
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = var.sg_ingress
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null

    }
  ]

  tags = {
    Name        = "${var.cluster_name}-${var.service_name}-sg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.cluster_name}-${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
  tags = {
    Name        = "${var.cluster_name}-${var.service_name}-tg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = var.alb_listener_443
  priority     = var.alb_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
}

/**
 * Service discovery setting
 **/
resource "aws_service_discovery_service" "this" {
  name = "${var.cluster_name}-${var.service_name}"
  dns_config {
    namespace_id   = var.svc_discovery_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "this" {
  name                   = "${var.cluster_name}-${var.service_name}"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.this.id
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  desired_count          = var.ecs_task_count
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = aws_security_group.sg_fargate[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "${var.service_name}-container"
    container_port   = var.container_port
  }
  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_mem
  execution_role_arn       = var.ecs_task_role
  task_role_arn            = var.ecs_task_role
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = var.parameter ? data.template_file.task_definition_parameter.rendered : data.template_file.task_definition.rendered
}

data "template_file" "task_definition_parameter" {
  template = <<CONTAINER_DEFINITION
[
      {
          "name": "${var.service_name}-container",
          "image": "nginx",
          "essential": true,
          "portMappings": [
                  {
                    "containerPort": ${var.container_port}, 
                    "hostPort": ${var.container_port}
            }
          ],
          "memory": ${var.ecs_task_mem},
          "secrets": [
            {
              "valueFrom": "${var.secretsmanager_arn}",
              "name": "secret_variables"
            }],
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          }
      }
  ]
CONTAINER_DEFINITION
}

data "template_file" "task_definition" {
  template = <<CONTAINER_DEFINITION
[
      {
          "name": "${var.service_name}-container",
          "image": "httpd",
          "essential": true,
          "portMappings": [
                  {
                    "containerPort": ${var.container_port}, 
                    "hostPort": ${var.container_port}
            }
          ],
          "memory": ${var.ecs_task_mem},
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          }
      }
  ]
CONTAINER_DEFINITION
}
