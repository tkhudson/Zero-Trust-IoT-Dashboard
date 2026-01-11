terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  # Remote state configuration - will be configured after initial deployment
  # backend "azurerm" {
  #   resource_group_name  = "rg-zerotrust-iot-state-eastus"
  #   storage_account_name = "stzerotrustiostatexxxxx"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    storage {
      # Delete blobs and containers on storage account deletion
      delete_retention_policy_enabled = false
    }
  }
}

# Generate random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Local values for consistent naming
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CostCenter  = "Portfolio"
    Purpose     = "Zero-Trust-IoT-Demo"
  }
  
  name_suffix = "${var.environment}-${random_string.suffix.result}"
  
  # Resource naming convention: type-project-purpose-location-environment
  resource_group_name = "rg-${var.project_name}-${var.location}-${var.environment}"
  storage_name        = "st${replace(var.project_name, "-", "")}state${random_string.suffix.result}"
  iot_hub_name        = "iot-${var.project_name}-${var.location}-${local.name_suffix}"
  vnet_name          = "vnet-${var.project_name}-${var.location}-${local.name_suffix}"
  nsg_name           = "nsg-${var.project_name}-iot-${var.location}-${local.name_suffix}"
  static_app_name    = "stapp-${var.project_name}-${var.location}-${local.name_suffix}"
}