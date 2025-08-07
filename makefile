# === Makefile for Node.js + Terraform + Docker ===
SRC_DIR=./src
BACKEND_DIR=./backend/Models
INFRA_DIR=infra/terraform-erick
ENV ?= dev

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
	@if [ -f $(FRONTEND_DIR)/package.json ]; then cd $(FRONTEND_DIR) && npm ci; fi

# --- Lint ---
Biome: check-npm
	@echo "🔍 Linting frontend..."
	cd $(SRC_DIR) && npx biome check .
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
