# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "public" {
    count                   = length(var.public_subnets)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnets[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true


    tags = {
        name = "${var.environment}-public-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "private" {
    count             = length(var.private_subnets)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnets[count.index]
    availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

    tags = {
        name = "${var.environment}-private-subnet-${count.index + 1}"
    }
}

# Gateways
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.environment}_internet_gateway"
    }
}

resource "aws_nat_gateway" "nat_gw" {
    count = length(var.private_subnets)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.private[count.index].id

    tags = {
        Name = "${var.environment}_nat_gateway"
    }

    depends_on = [aws_internet_gateway.igw]
}

#Elastic IP for Gatewway
resource "aws_eip" "nat" {
    count      = length(var.private_subnets)
    domain     = "vpc"
    depends_on = [aws_internet_gateway.igw]
}

# Route Tables & Associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}_main_public_subnet_route_table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_subnets)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "${var.environment}_main_private_subnet_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}