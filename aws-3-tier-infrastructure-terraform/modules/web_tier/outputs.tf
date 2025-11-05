output "alb_dns" {
    value = aws_lb.public_facing.dns_name
}