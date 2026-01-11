#!/bin/bash

# Configure Terraform Remote State Backend
set -e

echo "🔄 Configuring Terraform Remote State Backend"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get storage account details from Terraform outputs
print_status "Getting storage account details..."

RESOURCE_GROUP=$(terraform output -raw resource_group_name)
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)

if [ -z "$RESOURCE_GROUP" ] || [ -z "$STORAGE_ACCOUNT" ]; then
    print_error "Could not get storage account details from Terraform outputs."
    print_error "Make sure you've run 'terraform apply' first."
    exit 1
fi

# Get storage account key
print_status "Getting storage account key..."
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' \
    --output tsv)

if [ -z "$STORAGE_KEY" ]; then
    print_error "Could not retrieve storage account key."
    exit 1
fi

# Create backend configuration
print_status "Creating backend configuration..."

cat > backend.tf << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
EOF

# Update main.tf to uncomment backend configuration
print_status "Updating main.tf backend configuration..."

# Create a backup
cp main.tf main.tf.backup

# Update main.tf - uncomment backend block
sed -i '' '
/# backend "azurerm"/,/# }/ {
    s/^  # //
}' main.tf

print_status "Backend configuration created!"

print_warning "IMPORTANT NEXT STEPS:"
echo "1. Commit your current state: git add . && git commit -m 'Add backend config'"
echo "2. Initialize backend: terraform init -migrate-state"
echo "3. Verify: terraform plan (should show no changes)"

print_status "Your Terraform state will now be stored remotely in Azure!"
print_status "Resource Group: $RESOURCE_GROUP"
print_status "Storage Account: $STORAGE_ACCOUNT"