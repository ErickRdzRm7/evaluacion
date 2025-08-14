#!/bin/sh
set -e

# --- Configuración ---
# El commit hash es una excelente etiqueta única
IMAGE_TAG=${HEAD_COMMIT:-$(git rev-parse --short HEAD)}

# Obtenemos el ID de la cuenta de AWS de forma segura
ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "==> Autenticando Docker con ECR en la región $REGION..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "==> Construyendo la imagen de Docker: $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG"
docker build -t $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG .

echo "==> Subiendo la imagen a ECR..."
docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG

echo "==> Generando archivo de variables para Terraform..."
# Este archivo será usado por 'terraform plan'
echo "image_tag = \"$IMAGE_TAG\"" > atlantis.tfvars

echo "Script finalizado. La imagen con la etiqueta '$IMAGE_TAG' está lista."