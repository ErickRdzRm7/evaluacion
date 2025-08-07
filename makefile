
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
