# =============================================================================
# IOT HUB (F1 FREE TIER ONLY)
# =============================================================================
resource "azurerm_iothub" "main" {
  name                = local.iot_hub_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  # F1 Free tier: 8,000 messages/day, up to 500 devices
  sku {
    name     = "F1"
    capacity = "1"  # Fixed for F1
  }
  
  # Zero-trust device authentication
  endpoint {
    type                       = "AzureIotHub.EventHub"
    connection_string          = ""  # Will be auto-generated
    name                       = "events"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    encoding                   = "JSON"
  }
  
  tags = merge(local.common_tags, {
    Purpose = "IoT-Device-Ingestion"
    Tier    = "F1-Free"
  })
  
  # Enforce minimum TLS version
  min_tls_version = "1.2"
  
  # Enable device identity and cloud-to-device messages
  cloud_to_device {
    max_delivery_count = 10
    default_ttl        = "PT1H"
    feedback {
      time_to_live       = "PT1H"
      max_delivery_count = 10
      lock_duration      = "PT30S"
    }
  }
  
  # Device streams for secure device communication
  file_upload {
    connection_string  = azurerm_storage_account.state.primary_connection_string
    container_name     = "deviceuploads"
    sas_ttl           = "PT1H"
    notifications     = false
    lock_duration     = "PT1M"
    default_ttl       = "PT1H"
    max_delivery_count = 10
  }
}

# Create container for device file uploads
resource "azurerm_storage_container" "device_uploads" {
  name                  = "deviceuploads"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# =============================================================================
# DEFENDER FOR IOT (FREE MONITORING)
# =============================================================================
# Note: Defender for IoT is automatically enabled on IoT Hubs
# The free tier includes basic monitoring, device inventory, and recommendations

# IoT Hub Diagnostic Settings for monitoring
resource "azurerm_monitor_diagnostic_setting" "iot_hub" {
  name               = "iot-hub-diagnostics"
  target_resource_id = azurerm_iothub.main.id
  storage_account_id = azurerm_storage_account.state.id

  enabled_log {
    category = "Connections"
  }
  
  enabled_log {
    category = "DeviceTelemetry"
  }
  
  enabled_log {
    category = "C2DCommands"
  }
  
  enabled_log {
    category = "DeviceIdentityOperations"
  }

  metric {
    category = "AllMetrics"
  }
}