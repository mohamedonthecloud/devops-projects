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

#VPC Variables
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

#DB Variables
variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}