#!/bin/bash

# Este script importa los recursos existentes a tu estado de Terraform.
# Asegúrate de ejecutarlo en el directorio raíz de tu proyecto de Terraform.

set -e

echo "--- Iniciando proceso de importación de recursos ---"
echo "Asegúrate de que estás en el directorio correcto de tu proyecto de Terraform."
echo "Se te pedirá confirmar cada comando de importación."
echo ""

# --- Variables de recursos ---
# Sustituye los valores con los ARNs/IDs que proporcionaste.
VPC_ID="vpc-01098ad7d35521549"
ECR_REPO_ARN="arn:aws:ecr:us-east-2:693041643423:repository/app-frontend"
IAM_ROLE_EXEC_ARN="arn:aws:iam::693041643423:role/app-ecs-task-execution-role"
IAM_ROLE_TASK_ARN="arn:aws:iam::693041643423:role/app-ecs-task-role"
IAM_POLICY_ARN="arn:aws:iam::693041643423:policy/ecs-exec-command-policy"
LOG_GROUP_FRONTEND="/ecs/app-frontend"

# --- Funciones de importación ---
function import_resource {
  RESOURCE_ADDRESS=$1
  RESOURCE_ID=$2
  
  read -p "Importar recurso: $RESOURCE_ADDRESS con ID: $RESOURCE_ID? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Ejecutando: terraform import $RESOURCE_ADDRESS '$RESOURCE_ID'"
    terraform import "$RESOURCE_ADDRESS" "$RESOURCE_ID"
    echo "Importación completada para $RESOURCE_ADDRESS."
    echo
  else
    echo "Saltando la importación de $RESOURCE_ADDRESS."
    echo
  fi
}

# --- Importar cada recurso ---

# VPC
import_resource "module.network.aws_vpc.main" "$VPC_ID"

# ECR Repository
import_resource "module.ecr.aws_ecr_repository.frontend_repo" "$ECR_REPO_ARN"

# IAM Roles
import_resource "module.ecs_frontend.aws_iam_role.ecs_task_execution_role" "$IAM_ROLE_EXEC_ARN"
import_resource "module.ecs_frontend.aws_iam_role.ecs_task_role" "$IAM_ROLE_TASK_ARN"

# IAM Policy
import_resource "module.ecs_frontend.aws_iam_policy.ecs_exec_command_policy" "$IAM_POLICY_ARN"

# CloudWatch Log Group
import_resource "module.ecs_frontend.aws_cloudwatch_log_group.frontend_logs" "$LOG_GROUP_FRONTEND"


# Import the IAM execution role
terraform import module.ecs_frontend.aws_iam_role.ecs_task_execution_role app-ecs-task-execution-role

# Import the IAM task role
terraform import module.ecs_frontend.aws_iam_role.ecs_task_role app-ecs-task-role

# Import the IAM policy. You'll need its ARN.
# You can find the ARN with: `aws iam list-policies --query "Policies[?PolicyName=='ecs-exec-command-policy'].Arn" --output text`
terraform import module.ecs_frontend.aws_iam_policy.ecs_exec_command_policy <ARN_DE_LA_POLITICA>

# Import the CloudWatch Log Groups
terraform import module.ecs_frontend.aws_cloudwatch_log_group.frontend_logs /ecs/app-frontend
terraform import module.monitoring.aws_cloudwatch_log_group.monitoring_log_group /ecs/app/monitoring

terraform import module.ecs_frontend.aws_iam_policy.ecs_exec_command_policy arn:aws:iam::693041643423:policy/ecs-exec-command-policy

# CloudWatch Log Group (Monitoring)
# Necesitas encontrar el ID de este recurso si ya existe.
# Por ahora, se usará el nombre.
LOG_GROUP_MONITORING="/ecs/app/monitoring"
import_resource "module.monitoring.aws_cloudwatch_log_group.monitoring_log_group" "$LOG_GROUP_MONITORING"

echo "--- Proceso de importación finalizado ---"
echo "Ahora, ejecuta 'terraform plan' para verificar que la configuración y el estado coinciden."
