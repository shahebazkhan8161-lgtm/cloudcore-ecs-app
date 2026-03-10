variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "cloudcore-app"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  default = 80
}

variable "container_cpu" {
  default = 256
}

variable "container_memory" {
  default = 512
}

variable "desired_count" {
  default = 1
}

variable "environments" {
  default = ["uat", "prod"]
}