# Zero-Trust IoT Dashboard with Azure

**Developer:** Tyler Hudson (tkhudson)
**Project:** Enterprise Zero-Trust IoT Architecture on Azure
**Cost:** $0.00 (Free tier implementation)

A complete **Zero-Trust IoT security demonstration** using Azure's free tier services, showcasing real IoT device simulation, security monitoring, and Infrastructure as Code (IaC) best practices.

## Project Overview

This project demonstrates enterprise-grade Zero-Trust IoT architecture using **100% Azure free tier** resources. Perfect for cybersecurity portfolios, cloud certifications, and demonstrating real-world Azure skills.

### Key Features

- **Infrastructure as Code**: Complete Terraform deployment
- **Real IoT Simulation**: Actual devices sending telemetry to Azure IoT Hub
- **Zero-Trust Security**: Network segmentation, device authentication, anomaly detection
- **Live Dashboard**: Real-time monitoring and visualization
- **Cost-Safe**: 100% free tier usage with built-in cost monitoring
- **Production-Ready**: Professional development practices and security

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Azure Cloud (Free Tier)                 │
├─────────────────────────────────────────────────────────────────┤
│  Zero-Trust Network Segmentation                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Virtual       │  │  Network        │  │ Private       │ │
│  │ Network       │  │  Security       │  │ Endpoints     │ │
│  │ 10.0.0.0/16   │  │  Groups (NSG)   │  │ (Optional)    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                               │
│ IoT Hub F1 (Free Tier)                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Temperature    │  │ Humidity      │  │  Motion       │ │
│  │ Sensor-01     │  │  Monitor-02     │  │  Detector-03    │ │
│  │ Zone-1        │  │  Zone-2       │  │  Zone-3       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                               │
│ Microsoft Defender for IoT                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Security      │  │  Anomaly      │  │ Threat        │ │
│  │ Monitoring    │  │ Detection     │  │  Intelligence   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                               │
│ Static Web Apps (Free Tier)                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Real-time      │  │ Security      │  │ System        │ │
│  │  Dashboard      │  │ Alerts        │  │ Metrics       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   Local Development                           │
├─────────────────────────────────────────────────────────────────┤
│  📝 Infrastructure as Code (Terraform)                         │
│  🐍 Python IoT Device Simulation                               │
│ HTML/CSS/JavaScript Dashboard                              │
│ Automated Setup & Deployment Scripts                      │
└─────────────────────────────────────────────────────────────────┘
```

## Zero-Trust Security Implementation

### Network Segmentation

- **Virtual Network**: Isolated 10.0.0.0/16 address space
- **Subnets**: Segmented IoT device zones (zone-1, zone-2, zone-3)
- **NSG Rules**: Deny-all-by-default with specific allow rules
- **Service Endpoints**: Secure Azure service communication

### Device Authentication

- **Individual Device Certificates**: Each device has unique credentials
- **TLS 1.2+ Encryption**: All communication encrypted in transit
- **Connection String Security**: Per-device access keys stored securely
- **MQTT over TLS**: Secure telemetry transmission on port 8883

### Continuous Monitoring

- **Defender for IoT**: Real-time threat detection
- **Diagnostic Logging**: All device activities logged
- **Anomaly Detection**: Simulated security events for demonstration
- **Behavioral Analysis**: Device pattern monitoring

## Quick Start

### Prerequisites

- Azure account (free tier)
- Terraform installed
- Azure CLI installed
- Python 3.8+ installed
- Git installed

### 1-Click Deployment

```bash
./setup.sh
```

### Manual Setup

```bash
# 1. Deploy infrastructure
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 2. Register IoT devices
cd device-simulation
./setup_devices.sh

# 3. Start simulation
source venv/bin/activate
python iot_simulator.py

# 4. View dashboard
# Visit your Static Web App URL or run locally:
cd ../dashboard
python3 -m http.server 8080
```

## Technology Stack

### Infrastructure

- **Azure IoT Hub F1**: Device management & telemetry ingestion
- **Azure Static Web Apps**: Frontend hosting (free tier)
- **Azure Storage**: Terraform state management
- **Azure Virtual Network**: Network segmentation
- **Azure NSG**: Network security rules
- **Microsoft Defender for IoT**: Security monitoring

### Development

- **Terraform**: Infrastructure as Code
- **Python**: IoT device simulation
- **Azure IoT SDK**: Device communication
- **HTML/CSS/JavaScript**: Dashboard frontend
- **Chart.js**: Data visualization
- **Azure CLI**: Resource management

## Real Data Flow

### IoT Simulation (REAL DEVICES)

```python
# Actual Azure IoT Hub connections
await device.connect()  # TLS 1.2 MQTT connection
telemetry = generate_telemetry()  # Real sensor data
await device.send_message(telemetry)  # Actual messages to Azure

# Result: Real messages in Azure IoT Hub!
```

### Dashboard (LIVE MONITORING)

- **Real-time Charts**: Live telemetry visualization
- **Device Status**: Actual connection states
- **Security Alerts**: Defender for IoT findings
- **System Metrics**: True Azure resource usage

## Cost Breakdown (FREE!)

| Service          | Tier        | Usage            | Cost            |
| ---------------- | ----------- | ---------------- | --------------- |
| IoT Hub          | F1 Free     | 12/8,000 msg/day | $0.00           |
| Static Web Apps  | Free        | <100GB/month     | $0.00           |
| Virtual Network  | Always Free | Standard usage   | $0.00           |
| Storage Account  | Free Tier   | <5GB             | $0.00           |
| Defender for IoT | Free on F1  | Basic monitoring | $0.00           |
| **Total**  |             |                  | **$0.00** |

### Cost Monitoring

```bash
# Built-in cost monitoring
./scripts/cost-monitor.sh

# Safe destruction when done
./scripts/destroy.sh
```

## Learning Outcomes

### For Cybersecurity Professionals

- Zero-Trust architecture patterns
- IoT security best practices
- Azure security service integration
- Network segmentation strategies
- Threat detection and response

### For Cloud Engineers

- Infrastructure as Code with Terraform
- Azure service integration
- Cost optimization techniques
- Resource lifecycle management
- CI/CD pipeline concepts

### For DevOps Engineers

- Multi-service orchestration
- Environment management
- Monitoring and observability
- Automation scripting
- Security-first development

## Project Structure

```
Zero-Trust-iot-dash/
├── Infrastructure (Terraform)
│ ├── main.tf                 # Provider & core config
│ ├── networking.tf          # VNet, NSG, security
│ ├── iot.tf                 # IoT Hub, Defender
│ ├── webapp.tf              # Static Web App
│ ├── variables.tf           # Configuration variables
│ └── outputs.tf             # Resource outputs
│
├── Device Simulation
│ ├── iot_simulator.py       # Python device simulation
│ ├── setup_devices.sh       # Device registration
│ ├── requirements.txt       # Python dependencies
│ └── device_connections.json # Device credentials (auto-generated)
│
├── Dashboard
│ ├── index.html             # Dashboard frontend
│ ├── styles.css             # UI styling
│ ├── dashboard.js           # Real-time functionality
│ └── staticwebapp.config.json # SWA configuration
│
├── Scripts
│ ├── setup.sh               # One-click deployment
│ ├── cost-monitor.sh        # Cost tracking
│ ├── configure-backend.sh   # Remote state setup
│ └── destroy.sh             # Safe cleanup
│
└── 📚 Documentation
    ├── README.md              # This file
    ├── ARCHITECTURE.md        # Technical deep-dive
    └── DEMO.md               # Demo script for interviews
```

## Demo Script

### 1. Infrastructure Overview

```bash
# Show Terraform configuration
code main.tf

# Demonstrate infrastructure deployment
terraform plan
```

### 2. Zero-Trust Security

```bash
# Network segmentation
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name>

# Device authentication
cat device-simulation/device_connections.json
```

### 3. Real IoT Simulation

```bash
# Start device simulation
cd device-simulation
python iot_simulator.py

# Show Azure portal IoT Hub metrics
```

### 4. Live Dashboard

```bash
# Open dashboard
open http://localhost:8080

# Demonstrate real-time data
# Point out security features
```

### 5. Cost Management

```bash
# Show cost monitoring
./scripts/cost-monitor.sh

# Demonstrate safe cleanup
./scripts/destroy.sh
```

## Portfolio Value

### Demonstrates Skills

- **Azure Cloud Architecture**: Real cloud service integration
- **Security Engineering**: Zero-Trust implementation
- **Infrastructure as Code**: Professional Terraform usage
- **DevOps Practices**: Automation and monitoring
- **Cost Management**: Resource optimization
- **Full-Stack Development**: End-to-end solution

## Advanced Features

### Remote State Management

```bash
# Configure Terraform remote state
./scripts/configure-backend.sh
```
