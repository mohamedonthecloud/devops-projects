variable "environment" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "public_lb_sg" {
    type = string
}

variable "public_subnets" {
    type = list(string)
}

variable "public_sg" {
    type = string
}

variable "vpc_id" {
    type = string
}