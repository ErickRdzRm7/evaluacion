resource "aws_ecr_repository" "frontend_repo" {
  name = "${var.app_name}-frontend"
  
}
