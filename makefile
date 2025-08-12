#include .env
#export $(shell sed 's/=.*//' .env)
# === Makefile for Node.js + Terraform + Docker ===
ENV ?= prod
IMAGE_NAME ?= dockerfile
SRC_DIR=./src
INFRA_DIR=infra/terraform-erick
BRANCH_NAME := $(shell git rev-parse --abbrev-ref HEAD | tr '/' '-')
COMMIT_HASH := $(shell git rev-parse --short HEAD)
IMAGE_TAG ?= $(if $(VERSION),$(VERSION),$(BRANCH_NAME)-$(COMMIT_HASH))
ECR_REPO=app-frontend
ECR_REGISTRY=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(ECR_REPO)
# --- Validation helpers ---
check-npm:
	@command -v npm >/dev/null 2>&1 || (echo " npm is not installed." && exit 1)

check-terraform:
	@command -v terraform >/dev/null 2>&1 || (echo " terraform is not installed." && exit 1)

check-docker:
	@command -v docker >/dev/null 2>&1 || (echo " docker is not installed." && exit 1)

check-awscli:
	@command -v az >/dev/null 2>&1 || (echo " AWS CLI is not installed." && exit 1)

verify-dirs:
	@test -d "$(SRC_DIR)" || (echo " Frontend dir $(SRC_DIR) not found" && exit 1)
	@test -d "$(INFRA_DIR)" || (echo " Infra dir $(INFRA_DIR) not found" && exit 1)

check-env:
ifndef ENV
	$(error ENV is not set. Usage: make <target> ENV=dev|staging|prod)
endif

# --- Node.js Tasks ---
install: check-npm verify-dirs
	@echo "Installing dependencies..."
	@if [ -f package.json ]; then npm install ci; fi
	@if [ -f $(SRC_DIR)/package.json ]; then cd $(SRC_DIR) && npm install ci; fi

install-ci: check-npm verify-dirs
	@if [ -f package.json ]; then npm ci; fi
	@if [ -f $(SRC_DIR)/package.json ]; then cd $(SRC_DIR) && npm ci; fi
	
# --- Lint ---
Lint: check-npm
	@echo "🔍 Linting frontend..."
	npm run lint -- --fix
# --- Tests ---
test: check-npm verify-dirs
	@echo "Running frontend unit tests..."
	cd $(SRC_DIR) && npx vitest run --coverage

test-watch:
	cd $(SRC_DIR) && npx vitest

# --- Dev Server ---
dev: check-npm verify-dirs
	@echo "Starting dev server..."
	cd $(SRC_DIR) && npm run dev


# --- Terraform ---
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

# --- Docker -------

# Build and Push Docker Image frontend

docker-build-push-frontend: check-env
	@echo "Building multi-arch Docker image with tag $(IMAGE_TAG) and latest (if main)..."
	docker buildx create --use || true

	# Build and push branch+commit tag
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(ECR_REGISTRY):$(IMAGE_TAG) \
		--push \
		.

ifeq ($(BRANCH_NAME),main)
	# Build and push latest tag (solo main)
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(ECR_REGISTRY):latest \
		--push \
		.
endif

	@echo "Done: pushed images."

update-ecs-service:
		@echo "Updating ECS service..."
		aws ecs update-service --cluster $(ECS_CLUSTER_NAME) --service $(ECS_SERVICE_NAME) --force-new-deployment --region $(REGION)