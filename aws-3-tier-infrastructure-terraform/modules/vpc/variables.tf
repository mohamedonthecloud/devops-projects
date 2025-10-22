variable "environment" {
    type = string
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "availability_zones" {
    type = list(string)
    default = ["eu-west-2a", "eu-west-2b"]
}

variable "private_subnets" {
    type = list(string)
    default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "public_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}
