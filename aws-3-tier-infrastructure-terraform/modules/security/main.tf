# Public Facing Load Balancer Security Group Information
resource "aws_security_group" "public_lb" {
  name        = "${var.environment}_public_lb"
  description = "Security Group for Public Facing Load Balancer"
  vpc_id      = module.vpc.aws_vpc.main.id
  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  security_group_id = aws_security_group.public_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "https_ingress" {
  security_group_id = aws_security_group.public_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "web_tier_egress" {
  security_group_id = aws_security_group.public_lb.id

  referenced_security_group_id = aws_security_group.web_tier_instances.id
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

# Web Tier Security Group Information
resource "aws_security_group" "web_tier_instances" {
  name        = "${var.environment}_web_tier_instances"
  description = "Security Group for Web Tier Instances"
  vpc_id      = module.vpc.aws_vpc.main.id
  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "public_lb_ingress" {
  security_group_id = aws_security_group.web_tier_instances.id

  referenced_security_group_id = aws_security_group.public_lb.id
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "http_egress" {
  security_group_id = aws_security_group.example.id

  referenced_security_group_id = aws_security_group.private_lb.id
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

# Private Load Balancer Security Group Information
resource "aws_security_group" "private_lb" {
  name        = "${var.environment}_private_lb"
  description = "Security Group for Web Tier Instances"
  vpc_id      = module.vpc.aws_vpc.main.id
  tags = local.tags
}


resource "aws_vpc_security_group_ingress_rule" "web_tier_ingress" {
  security_group_id = aws_security_group.private_lb.id

  referenced_security_group_id = aws_security_group.web_tier_instances.id
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "app_tier_egress" {
  security_group_id = aws_security_group.example.id

  referenced_security_group_id = aws_security_group.app_tier_instances.id
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

# App Tier Security Group Information
resource "aws_security_group" "app_tier_instances" {
  name        = "${var.environment}_private_lb"
  description = "Security Group for Web Tier Instances"
  vpc_id      = module.vpc.aws_vpc.main.id
  tags = local.tags
}


resource "aws_vpc_security_group_ingress_rule" "private_lb_ingress" {
  security_group_id = aws_security_group.app_tier_instances.id

  referenced_security_group_id = aws_security_group.private_lb
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "app_tier_egress" {
  security_group_id = aws_security_group.app_tier_instances.id

  referenced_security_group_id = aws_security_group.db_sh
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

# Database Security Group Information
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}_db_security_group"
  description = "Security Group for Database"
  vpc_id      = module.vpc.aws_vpc.main.id
  tags = local.tags
}


resource "aws_vpc_security_group_ingress_rule" "app_tier_ingress" {
  security_group_id = aws_security_group.app_tier

  referenced_security_group_id = aws_security_group.app_tier_instances.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_egress_rule" "app_tier_egress" {
  security_group_id = aws_security_group.app_tier_instances

  referenced_security_group_id = aws_security_group.app_tier_instances.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}
