output "ecs_cluster_name" {
  value = aws_ecs_cluster.aws_ecs_cluster.name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.aws_ecs_cluster.id
}

output "ecs_taskRole_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "svc_discovery_id" {
  value = aws_service_discovery_private_dns_namespace.this.id
}

