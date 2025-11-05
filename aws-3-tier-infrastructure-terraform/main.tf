module "main_vpc" {
  source                   = "./modules/vpc"
  environment              = var.environment
  availability_zones       = var.availability_zones
  vpc_cidr                 = var.vpc_cidr
  app_private_subnet_cidrs = var.app_private_subnet_cidrs
  db_private_subnet_cidrs  = var.db_private_subnet_cidrs
  public_subnet_cidrs      = var.public_subnet_cidrs
}

module "web_tier" {
  source = "./modules/web_tier"
  environment = var.environment
  instance_type = var.instance_type
  public_sg = module.security_groups.web_tier_instance_sg_id
  public_subnets = module.main_vpc.public_subnets_ids
  public_lb_sg = module.security_groups.public_lb_sg_id
  vpc_id = module.main_vpc.vpc_id
}

module "app_tier" {
  source = "./modules/app_tier"
  environment = var.environment
  instance_type = var.instance_type
  private_sg = module.security_groups.app_tier_instance_sg_id
  private_subnets = module.main_vpc.app_private_subnets_ids
  private_lb_sg = module.security_groups.private_lb_sg_id
  vpc_id = module.main_vpc.vpc_id
}

module "db_tier" {
  source = "./modules/db_tier"
  environment = var.environment
  db_username = var.db_username
  db_password = var.db_password
  db_private_subnets = module.main_vpc.db_private_subnets_ids
  db_sg = module.security_groups.db_tier_instance_sg_id
}

module "security_groups" {
  source = "./modules/security"
  environment = var.environment
  vpc_id = module.main_vpc.vpc_id
}