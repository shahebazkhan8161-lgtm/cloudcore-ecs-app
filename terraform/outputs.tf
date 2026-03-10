output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.cloudcore.dns_name
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.cloudcore.name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.cloudcore.name
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.cloudcore.repository_url
  description = "ECR Repository URL"
}