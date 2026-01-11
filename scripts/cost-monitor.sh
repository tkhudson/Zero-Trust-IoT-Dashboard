#!/bin/bash

# Cost Monitoring and Safety Script
set -e

echo "💰 Zero-Trust IoT Cost Monitor"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check current costs
print_status "Checking current Azure costs..."

SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Get current month costs
COSTS=$(az consumption usage list --start-date $(date -d "1 month ago" +%Y-%m-01) --end-date $(date +%Y-%m-%d) --query "[?contains(instanceName, 'zerotrust-iot')].pretaxCost" -o tsv 2>/dev/null | awk '{sum += $1} END {print sum}')

if [ -z "$COSTS" ] || [ "$COSTS" = "0" ]; then
    print_status "Current costs: $0.00 (FREE! 🎉)"
else
    print_warning "Current costs: $${COSTS}"
fi

# Check IoT Hub message count (requires IoT extension)
print_status "Checking IoT Hub usage..."

# Get resource group and IoT Hub name from Terraform
RG=$(terraform output -raw resource_group_name 2>/dev/null)
IOT_HUB=$(terraform output -raw iot_hub_name 2>/dev/null)

if [ ! -z "$RG" ] && [ ! -z "$IOT_HUB" ]; then
    # Check IoT Hub metrics for today
    echo "Resource Group: $RG"
    echo "IoT Hub: $IOT_HUB"
    
    # Get device count
    DEVICE_COUNT=$(az iot hub device-identity list --hub-name "$IOT_HUB" --query "length(@)" -o tsv 2>/dev/null || echo "0")
    echo "Registered devices: $DEVICE_COUNT/500 (F1 limit)"
    
    if [ "$DEVICE_COUNT" -gt 450 ]; then
        print_warning "Approaching device limit!"
    fi
else
    print_warning "IoT Hub not deployed yet. Run 'terraform apply tfplan' first."
fi

# Storage usage check
print_status "Checking storage usage..."
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name 2>/dev/null || echo "")
if [ ! -z "$STORAGE_ACCOUNT" ]; then
    # Check blob storage usage
    BLOB_USAGE=$(az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name tfstate --query "length(@)" -o tsv 2>/dev/null || echo "0")
    echo "Terraform state files: $BLOB_USAGE"
    
    # Check device uploads container
    UPLOAD_USAGE=$(az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name deviceuploads --query "length(@)" -o tsv 2>/dev/null || echo "0")
    echo "Device uploads: $UPLOAD_USAGE files"
fi

# Safety recommendations
echo ""
print_status "Cost Safety Recommendations:"
echo "1. Monitor daily: Run this script daily"
echo "2. Set message limits in device simulation (keep <500/day per device)"
echo "3. Check Azure Cost Management: https://portal.azure.com/#view/Microsoft_Azure_CostManagement"
echo "4. DESTROY when done: Run './scripts/destroy.sh'"

print_warning "FREE TIER LIMITS:"
echo "• IoT Hub F1: 8,000 messages/day total (all devices)"
echo "• Storage: 5GB + 20,000 operations/month"
echo "• Static Web App: 100GB bandwidth/month"

echo ""
print_status "To set up cost alerts, run: ./scripts/setup-cost-alerts.sh"