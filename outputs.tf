# Dev: Tyler Hudson - tkhudson
# Terraform Output Values
# Exposes critical resource information for post-deployment configuration

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "iot_hub_name" {
  description = "Name of the IoT Hub"
  value       = azurerm_iothub.main.name
}

output "iot_hub_hostname" {
  description = "IoT Hub hostname"
  value       = azurerm_iothub.main.hostname
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account for state management"
  value       = azurerm_storage_account.state.name
}

output "static_web_app_url" {
  description = "Static Web App default hostname"
  value       = azurerm_static_web_app.dashboard.default_host_name
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "IoT subnet ID"
  value       = azurerm_subnet.iot.id
}

output "nsg_name" {
  description = "Network Security Group name"
  value       = azurerm_network_security_group.iot.name
}