output "web_tier_instance_sg_id" {
    value = aws_security_group.web_tier_instances.id
}

output "public_lb_sg_id" {
    value = aws_security_group.public_lb.id
}

output "app_tier_instance_sg_id" {
    value = aws_security_group.app_tier_instances.id
}

output "private_lb_sg_id" {
    value = aws_security_group.private_lb.id
}

output "db_tier_instance_sg_id" {
    value = aws_security_group.db_sg.id
}