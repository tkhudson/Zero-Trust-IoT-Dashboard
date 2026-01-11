#!/bin/bash

# Zero-Trust IoT Dashboard - Setup Script
set -e

echo "🚀 Zero-Trust IoT Dashboard Setup Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Run 'az login' first."
    exit 1
fi

print_status "Prerequisites check passed!"

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Validate configuration
print_status "Validating Terraform configuration..."
terraform validate

# Format code
print_status "Formatting Terraform code..."
terraform fmt

# Plan deployment
print_status "Creating Terraform plan..."
terraform plan -out=tfplan

print_status "Setup complete! Next steps:"
echo "1. Review the plan above"
echo "2. Run: terraform apply tfplan"
echo "3. After apply, configure remote state with: ./scripts/configure-backend.sh"

print_warning "IMPORTANT: This uses Azure FREE TIERS only!"
print_warning "Monitor your costs at: https://portal.azure.com/#view/Microsoft_Azure_CostManagement"