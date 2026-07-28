variable "aws_region" {
  description = "AWS region in which the infrastructure will be deployed."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Base name used for project resources."
  type        = string
  default     = "aws-application"
}

variable "environment" {
  description = "Deployment environment, such as dev, staging, or production."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the project VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the two public subnets."
  type        = list(string)

  default = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDR blocks must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the two private subnets."
  type        = list(string)

  default = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDR blocks must be provided."
  }
}

variable "container_port" {
  description = "Port exposed by the backend container."
  type        = number
  default     = 12008

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "The container port must be between 1 and 65535."
  }
}

variable "desired_task_count" {
  description = "Number of backend ECS tasks maintained by the service."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_task_count >= 1
    error_message = "The desired task count must be at least 1."
  }
}

variable "owner" {
  description = "Owner value added to AWS resource tags."
  type        = string
  default     = "Shayke"
}