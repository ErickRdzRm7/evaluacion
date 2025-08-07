#!/bin/bash

echo "🧹 Limpiando bloqueos de Terraform..."

rm -rf .terraform
rm -f terraform.tfstate.lock.info
rm -f .terraform.tfstate.lock.info
rm -f .terraform.lock.hcl

echo "✅ Reinicializando Terraform..."
terraform init

echo "✨ Listo. Puedes correr: terraform apply -lock=false"
