output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_service_id" {
  value = aws_ecs_service.this.id
}

output "ecs_task_security_group_id" {
  value = aws_security_group.ecs.id
}

output "ecs_task_definition_arn" {
  value = join("", aws_ecs_task_definition.this.*.arn)
}


output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role. This role resolves `secrets` at container start, so grants for Secrets Manager or SSM attach here -- not to the task role."
  value       = join("", aws_iam_role.ecs_task_execution_role.*.name)
}

output "ecs_task_execution_role_arn" {
  value = join("", aws_iam_role.ecs_task_execution_role.*.arn)
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role. This is the identity the application code runs as."
  value       = join("", aws_iam_role.ecs_task_role.*.name)
}
