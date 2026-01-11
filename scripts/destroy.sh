#!/bin/bash

# Complete Infrastructure Destruction Script
set -e

echo "🗑️  Zero-Trust IoT Infrastructure Destroyer"
echo "==========================================="

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

print_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
print_error() { echo -e "${RED}[DANGER]${NC} $1"; }
print_status() { echo -e "${GREEN}[✓]${NC} $1"; }

print_error "THIS WILL DESTROY ALL AZURE RESOURCES!"
print_warning "This action CANNOT be undone!"

echo ""
print_status "Resources that will be destroyed:"
terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[].address' 2>/dev/null || echo "- All Terraform-managed resources"

echo ""
read -p "Type 'DESTROY' to confirm: " confirmation

if [ "$confirmation" != "DESTROY" ]; then
    echo "Destruction cancelled."
    exit 1
fi

print_warning "Starting destruction in 5 seconds... Press Ctrl+C to abort!"
sleep 5

# Destroy infrastructure
print_status "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

# Clean up local files
print_status "Cleaning up local state..."
rm -f terraform.tfstate*
rm -f tfplan
rm -rf .terraform/

print_status "Infrastructure destroyed successfully!"
print_warning "Cost monitoring: Check Azure portal to verify all resources are gone."
print_warning "Final cost check in 24 hours recommended."

echo ""
print_status "To rebuild later:"
echo "1. Run: ./setup.sh"
echo "2. Run: terraform apply tfplan"