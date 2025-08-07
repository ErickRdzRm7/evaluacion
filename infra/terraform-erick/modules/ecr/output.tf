output "ecr_frontend_repo_url" {
  description = "URL del repositorio ECR del frontend"
  value       = aws_ecr_repository.frontend_repo.repository_url
}
