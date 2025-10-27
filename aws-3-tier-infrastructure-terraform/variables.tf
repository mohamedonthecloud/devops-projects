# Environment Specific Variables
variable "environment" {
  description = "Name of the environment (e.g., dev, prod)"
  type        = string
}

variable "access_key" {
  description = "Name of public access key"
  type        = string
}

variable "secret_access_key" {
  description = "Name of private access key"
  type        = string
}

variable "instance_type" {
  description = "Size of instance"
  type        = string
}

#VPC Module Variables
variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "app_private_subnet_cidrs" {
  type = list(string)
}

variable "db_private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}
