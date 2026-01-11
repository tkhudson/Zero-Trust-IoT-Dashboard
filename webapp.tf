# =============================================================================
# AZURE STATIC WEB APPS (FREE TIER)
# =============================================================================
resource "azurerm_static_web_app" "dashboard" {
  name                = local.static_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = "East US 2"  # Static Web Apps has limited region availability
  sku_tier            = "Free"
  sku_size            = "Free"
  
  tags = merge(local.common_tags, {
    Purpose = "IoT-Dashboard"
    Tier    = "Free"
  })
}

# =============================================================================
# RBAC AND ACCESS CONTROL (Zero-Trust Principles)
# =============================================================================

# IoT Hub Data Contributor role for admin
resource "azurerm_role_assignment" "iot_hub_admin" {
  count                = var.admin_object_id != "" ? 1 : 0
  scope                = azurerm_iothub.main.id
  role_definition_name = "IoT Hub Data Contributor"
  principal_id         = var.admin_object_id
}

# Storage Blob Data Contributor for state management
resource "azurerm_role_assignment" "storage_admin" {
  count                = var.admin_object_id != "" ? 1 : 0
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.admin_object_id
}

# Static Web App Contributor
resource "azurerm_role_assignment" "static_app_admin" {
  count                = var.admin_object_id != "" ? 1 : 0
  scope                = azurerm_static_web_app.dashboard.id
  role_definition_name = "Static Web App Contributor"
  principal_id         = var.admin_object_id
}