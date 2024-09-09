output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "ec2_instance_id" {
  value = module.ec2_instance.instance_id
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}
