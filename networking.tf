# Dev: Tyler Hudson - tkhudson
# Network Security Configuration - Zero-Trust Implementation
# Virtual network and security group rules for IoT isolation

# =============================================================================
# RESOURCE GROUP
# =============================================================================
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# STORAGE ACCOUNT FOR TERRAFORM STATE (Bootstrap)
# =============================================================================
resource "azurerm_storage_account" "state" {
  name                     = substr("st${replace(replace(var.project_name, "-", ""), "_", "")}${replace(random_string.suffix.result, "-", "")}", 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"

  tags = merge(local.common_tags, {
    Purpose = "Terraform-State-Management"
  })
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# =============================================================================
# VIRTUAL NETWORK & SECURITY
# =============================================================================
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = merge(local.common_tags, {
    Purpose = "Zero-Trust-Network-Segmentation"
  })
}

resource "azurerm_subnet" "iot" {
  name                 = "snet-iot-devices"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints for IoT Hub (when available in free tier)
  service_endpoints = ["Microsoft.Storage"]
}

# Network Security Group with Zero-Trust principles
resource "azurerm_network_security_group" "iot" {
  name                = local.nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = merge(local.common_tags, {
    Purpose = "IoT-Device-Security"
  })
}

# Zero-Trust NSG Rules: Deny all by default, allow specific
resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.iot.name
}

resource "azurerm_network_security_rule" "allow_https_outbound" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.iot.name
}

resource "azurerm_network_security_rule" "allow_iot_hub_amqp" {
  name                        = "AllowIoTHubAMQP"
  priority                    = 1100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5671", "5672"] # AMQP/AMQP over WebSocket
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.iot.name
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "iot" {
  subnet_id                 = azurerm_subnet.iot.id
  network_security_group_id = azurerm_network_security_group.iot.id
}