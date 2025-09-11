ENV ?= dev
SRC_DIR=./src
INFRA_DIR=infra/terraform-erick
#BRANCH_NAME := $(shell git rev-parse --abbrev-ref HEAD | tr '/' '-')
#COMMIT_HASH := $(shell git rev-parse --short HEAD)
#IMAGE_TAG := $(BRANCH_NAME)-$(COMMIT_HASH)

#ECR_REPO=app-frontend
#ECR_REGISTRY=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(ECR_REPO)

# --- Install ---
install-ci: check-npm verify-dirs
	@if [ -f package.json ]; then npm ci; fi
	@if [ -f $(SRC_DIR)/package.json ]; then cd $(SRC_DIR) && npm ci; fi
	
# --- Lint ---
Lint: check-npm
	@echo "Linting frontend..."
	npx biome check --fix .
	
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
