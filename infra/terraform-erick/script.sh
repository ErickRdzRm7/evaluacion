terraform import module.ecr.aws_ecr_repository.backend_repo eduia-backend2
terraform import module.ecr.aws_ecr_repository.frontend_repo eduia-frontend
terraform import module.ecs_backend.aws_ecr_repository.backend_repo eduia-backend

# --- IAM Roles ---
terraform import module.ecs_backend.aws_iam_role.ecs_task_execution eduia-ecs-execution-role
terraform import module.ecs_frontend.aws_iam_role.ecs_task_execution_role eduia-ecs-task-execution-role
terraform import module.ecs_frontend.aws_iam_role.ecs_task_role eduia-ecs-task-role

# --- CloudWatch Log Groups ---
terraform import module.ecs_frontend.aws_cloudwatch_log_group.frontend_logs /ecs/eduia-frontend
terraform import module.monitoring.aws_cloudwatch_log_group.monitoring_log_group /ecs/eduia/monitoring

# --- RDS Subnet Group ---
terraform import module.rds.aws_db_subnet_group.pg eduia-pg-subnet-group
