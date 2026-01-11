#!/bin/bash
# Dev: Tyler Hudson - tkhudson
# IoT Device Registration Script
# Registers devices with Azure IoT Hub and generates connection strings

# Device Registration Script for Zero-Trust IoT Demo
set -e

echo "🔐 Zero-Trust IoT Device Registration"
echo "===================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Get IoT Hub name from Azure directly
RESOURCE_GROUP="rg-zerotrust-iot-eastus-dev"
IOT_HUB=$(az iot hub list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

if [ -z "$IOT_HUB" ]; then
    print_error "IoT Hub not found in resource group: $RESOURCE_GROUP"
    print_error "Ensure Terraform deployment is complete."
    exit 1
fi

print_status "Using IoT Hub: $IOT_HUB"

# Install Azure IoT extension
print_status "Installing Azure CLI IoT extension..."
az extension add --name azure-iot --upgrade --yes

# Device definitions
DEVICES=(
    "zero-trust-temperature-sensor-01"
    "zero-trust-humidity-monitor-02"
    "zero-trust-motion-detector-03"
)

# Create devices and store connection strings
print_status "Creating devices in IoT Hub..."

echo "{" > device_connections.json
first=true

for device in "${DEVICES[@]}"; do
    print_status "Creating device: $device"
    
    # Create device identity
    az iot hub device-identity create \
        --hub-name "$IOT_HUB" \
        --device-id "$device" \
        --auth-method shared_private_key \
        --ee false \
        --output none
    
    # Get device connection string
    CONNECTION_STRING=$(az iot hub device-identity connection-string show \
        --hub-name "$IOT_HUB" \
        --device-id "$device" \
        --output tsv)
    
    # Add to JSON file
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> device_connections.json
    fi
    
    echo "  \"$device\": \"$CONNECTION_STRING\"" >> device_connections.json
    
    print_status "✅ Device $device registered"
done

echo "}" >> device_connections.json

print_status "Device registration complete!"

# Display summary
echo ""
print_status "Device Summary:"
az iot hub device-identity list --hub-name "$IOT_HUB" --query "[].deviceId" -o table

print_warning "Connection strings saved to: device_connections.json"
print_warning "Keep this file secure - it contains device credentials!"

echo ""
print_status "Next steps:"
echo "1. Install Python dependencies: pip install -r requirements.txt"
echo "2. Run simulation: python iot_simulator.py"
echo "3. Monitor in Azure portal: https://portal.azure.com"

# Create Python virtual environment setup
print_status "Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

print_status "🎉 Device setup complete! Ready to simulate!"
echo ""
print_warning "To run simulation:"
echo "cd device-simulation"
echo "source venv/bin/activate"
echo "python iot_simulator.py"