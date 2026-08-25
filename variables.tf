variable "tags" {
  description = "This is to help add tags to the provisioned AWS resources."
  type        = map(any)
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "default_resource_name" {
  description = "The default resource name"
  type        = string
  default     = "tf-resource"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "ecs_container_name" {
  description = "The name of the ECS container"
  type        = string
}

variable "ecs_container_image" {
  description = "The Docker image for the ECS container"
  type        = string
  default     = ""
}

variable "ecs_container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 3000
}

variable "ecs_desired_count" {
  description = "The desired number of tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "The maximum capacity for the ECS service"
  type        = number
  default     = 1
}

variable "ecs_min_capacity" {
  description = "The minimum capacity for the ECS service"
  type        = number
  default     = 1
}

variable "ecs_target_memory_utilization" {
  description = "The target memory utilization for the ECS service for autoscaling purposes"
  type        = number
  default     = 70
}

variable "ecs_target_cpu_utilization" {
  description = "The target CPU utilization for the ECS service for autoscaling purposes"
  type        = number
  default     = 60
}

variable "ecs_read_only_root_filesystem" {
  description = "Whether the container has a read-only root filesystem"
  type        = bool
  default     = false
}


variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "lb_security_group_id" {
  description = "The security group ID of the load balancer"
  type        = string
}

variable "fargate_cpu" {
  description = "The amount of CPU to reserve for the container"
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "The amount of memory to reserve for the container"
  type        = number
  default     = 512
}

variable "ecs_container_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps"
  default     = null
}

variable "create_ecs_task_definition" {
  description = "This is to create a new ECS task definition or use an existing one"
  type        = bool
  default     = true
}

variable "byo_ecs_task_definition_arn" {
  description = "This is the BYO (Bring Your Own) ECS task definition ARN for the application"
  type        = string
  default     = ""
}

variable "ecs_task_execution_policy_arn" {
  description = "This is the ECS task execution policy ARN for the application"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "cloudwatch_log_retention_in_days" {
  description = "The number of days to retain the logs in CloudWatch"
  type        = number
  default     = 365
}

variable "ecs_container_secrets" {
  description = "Secrets injected at container start, resolved by the task execution role. valueFrom is a Secrets Manager or SSM ARN, optionally suffixed with ':jsonKey::' to select one key from a JSON secret. The execution role must be granted read access to each ARN."
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}
