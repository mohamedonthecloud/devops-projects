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
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true


    tags = {
        name = "${var.environment}-public-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "app_tier" {
    count             = length(var.app_private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.app_private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

    tags = {
        name = "${var.environment}-app-private-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "db_tier" {
    count             = length(var.db_private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.db_private_subnet_cidrs[count.index]
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
    count = length(var.app_private_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.app_tier[count.index].id

    tags = {
        Name = "${var.environment}_nat_gateway"
    }

    depends_on = [aws_internet_gateway.igw]
}

#Elastic IP for Gatewway
resource "aws_eip" "nat" {
    count      = length(var.app_private_subnet_cidrs)
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

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.app_private_subnet_cidrs)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "${var.environment}_main_private_subnet_route_table"
  }
}

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.db_private_subnet_cidrs)

  tags = {
    Name = "${var.environment}_main_private_subnet_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_private" {
  count          = length(var.app_private_subnet_cidrs)
  subnet_id      = aws_subnet.app_tier[count.index].id
  route_table_id = aws_route_table.app_private[count.index].id
}

resource "aws_route_table_association" "db_private" {
  count          = length(var.db_private_subnet_cidrs)
  subnet_id      = aws_subnet.db_tier[count.index].id
  route_table_id = aws_route_table.db_private[count.index].id
}