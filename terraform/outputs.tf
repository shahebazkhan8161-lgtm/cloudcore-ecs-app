output "uat_alb_dns_name" {
  description = "UAT Application Load Balancer DNS name"
  value       = aws_lb.cloudcore["uat"].dns_name
}

output "prod_alb_dns_name" {
  description = "PROD Application Load Balancer DNS name"
  value       = aws_lb.cloudcore["prod"].dns_name
}

output "uat_ecs_cluster_name" {
  description = "UAT ECS Cluster name"
  value       = aws_ecs_cluster.cloudcore["uat"].name
}

output "prod_ecs_cluster_name" {
  description = "PROD ECS Cluster name"
  value       = aws_ecs_cluster.cloudcore["prod"].name
}

output "uat_ecs_service_name" {
  description = "UAT ECS Service name"
  value       = aws_ecs_service.cloudcore["uat"].name
}

output "prod_ecs_service_name" {
  description = "PROD ECS Service name"
  value       = aws_ecs_service.cloudcore["prod"].name
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.cloudcore.repository_url
  description = "ECR Repository URL"
}