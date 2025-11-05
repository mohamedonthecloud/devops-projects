output "application_url" {
  value = module.web_tier.alb_dns
}

output "vpc_id" {
  value = module.main_vpc.vpc_id
}

output "database_endpoint" {
  value = module.db_tier.db_endpoint
}