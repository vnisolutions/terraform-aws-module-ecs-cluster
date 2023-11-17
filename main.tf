resource "aws_ecs_cluster" "aws_ecs_cluster" {
  name = "${var.env}-${var.project_name}"
  tags = {
    Name        = "${var.env}-${var.project_name}"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.env}-${var.project_name}.internal"
  description = "Service Discovery Private DNS"
  vpc         = var.vpc_id
}
