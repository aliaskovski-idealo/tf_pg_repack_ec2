# aws_rds_cluster
output "rds_cluster_id" {
  description = "The ID of the cluster"
  value       = module.rds_aurora.cluster_id
}

output "rds_cluster_resource_id" {
  description = "The Resource ID of the cluster"
  value       = module.rds_aurora.cluster_resource_id
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = try(module.rds_aurora.cluster_endpoint, "")
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = module.rds_aurora.cluster_reader_endpoint
}

output "rds_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.rds_aurora.cluster_database_name
}

output "rds_cluster_port" {
  description = "The port"
  value       = module.rds_aurora.cluster_port
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = module.rds_aurora.cluster_master_username
  sensitive   = true
}

# aws_security_group
output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.rds_aurora.security_group_id
}

output "rds_secret_id" {
  value = aws_secretsmanager_secret.rds.id
}

output "rds_password" {
  value     = random_password.db_pass.result
  sensitive = true
}

output "rds_secret_name" {
  value = aws_secretsmanager_secret.rds.name
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = try(module.rds_aurora[0].cluster_members, "")
  sensitive   = true
}

output "sns_topic_arn" {
  description = "ARN of SNS topic"
  value       = try(module.alerting.sns_topic_arn, "")
}