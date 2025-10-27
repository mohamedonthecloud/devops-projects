variable "environment" {
    type = string
}

variable "db_private_subnets" {
    type = list(string)
}

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

variable "db_sg" {
    type = string
}