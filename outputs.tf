output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_service_id" {
  value = aws_ecs_service.this.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

