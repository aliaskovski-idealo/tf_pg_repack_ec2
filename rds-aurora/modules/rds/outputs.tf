# aws_rds_cluster
output "rds_db_instance_id" {
  description = "The ID of the instance"
  value       = module.rds_master.db_instance_id
}

output "rds_db_instance_resource_id" {
  description = "The Resource ID of the instance"
  value       = module.rds_master.db_instance_resource_id
}

output "rds_db_instance_endpoint" {
  description = "The instance endpoint"
  value       = replace(module.rds_master.db_instance_endpoint, ":${module.rds_master.db_instance_port}", "")
}

output "rds_db_instance_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.rds_master.db_instance_name
}

output "rds_db_instance_port" {
  description = "The port"
  value       = module.rds_master.db_instance_port
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = module.rds_master.db_instance_username
  sensitive   = true
}

# aws_security_group
output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = length(module.rds_master.db_instance_id) > 0 ? aws_security_group.allow_rds_connect.id : ""
}

output "rds_secret_id" {
  value = aws_secretsmanager_secret.rds.id
}

output "rds_password" {
  value = random_password.db_pass.result
}

output "rds_secret_name" {
  value = aws_secretsmanager_secret.rds.name
}
