variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "interview-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}
