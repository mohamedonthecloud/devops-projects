variable "environment" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "private_lb_sg" {
    type = string
}

variable "private_subnets" {
    type = list(string)
}

variable "private_sg" {
    type = string
}