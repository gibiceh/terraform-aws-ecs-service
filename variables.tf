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

