
# === Makefile for Node.js + Terraform + Docker ===
SRC_DIR=./src
INFRA_DIR=infra/terraform-erick
ENV ?= dev


name: CI/CD Pipeline - Frontend & Infra

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]
  workflow_dispatch:
    
permissions:
  id-token: write
  contents: read
    
env:
  NODE_VERSION: '24.3.0'
  APP_NAME: evaluacion
  DEPLOY_ENV: dev

jobs:
  ci-build-test:
    name: Build & Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: v24.3.0
          cache: 'npm'
          cache-dependency-path: |
            ./package-lock.json


verify-dirs:
	@test -d "$(SRC_DIR)" || (echo " Frontend dir $(SRC_DIR) not found" && exit 1)
	@test -d "$(INFRA_DIR)" || (echo " Infra dir $(INFRA_DIR) not found" && exit 1)
      - name: Install Node.js 
        run: make install
    
      - name: Install Node.js dependencies
        run: make install-ci


      - name: Lint 
        run: make Lint

      - name: Run Unit Tests
        run: make test
    
  cd-deploy-infra:
    name: Deploy Infrastructure
    needs: ci-build-test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch' || github.event_name == 'pull_request'


    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: ${{ secrets.REGION }}
      ENVIRONMENT: dev

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

# --- Dev Server ---
dev: check-npm verify-dirs
	@echo "Starting dev server..."
	cd $(SRC_DIR) && npm run dev

# --- Terraform --
terraform-init: check-terraform verify-dirs
	@echo "Terraform init in $(INFRA_DIR)..."
	cd $(INFRA_DIR) && terraform init

terraform-validate: check-terraform verify-dirs
	@echo "Validating Terraform..."
	cd $(INFRA_DIR) && terraform validate

terraform-plan:
	@echo "Running Terraform plan..."
	cd $(INFRA_DIR) && \
	terraform plan \
		-var-file="terraform.tfvars" \
		-out=tfplan.out


terraform-apply: check-terraform verify-dirs check-env
	@echo "Applying Terraform..."
	cd $(INFRA_DIR) && \
		terraform apply \
		-var-file="terraform.tfvars" \
		-auto-approve
      - name: Setup AWS CLI
        uses: aws-actions/configure-aws-credentials@v3 
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: us-east-2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.5

      - name: Terraform Init
        run: make terraform-init

      - name: Terraform Validate
        run: make terraform-validate

      - name: Terraform Plan
        run: make terraform-plan
        env:
          TF_VAR_environment: dev


      - name: Terraform Apply
        run: make terraform-apply
        env:
          TF_VAR_environment: dev
