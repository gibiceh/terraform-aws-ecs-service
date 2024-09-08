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

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "container_image" {
  description = "The Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}

variable "desired_count" {
  description = "The desired number of tasks"
  type        = number
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "lb_security_group_id" {
  description = "The security group ID of the load balancer"
  type        = string
}
