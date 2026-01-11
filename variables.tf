variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "zerotrust-iot"
}

variable "admin_object_id" {
  description = "Azure AD Object ID for admin access (run: az ad signed-in-user show --query id -o tsv)"
  type        = string
  default     = ""
}

variable "allowed_ip_range" {
  description = "Your public IP range for NSG rules (format: x.x.x.x/32)"
  type        = string
  default     = "0.0.0.0/0" # Will be restricted later
}

variable "device_count" {
  description = "Number of simulated IoT devices (max 5 for free tier)"
  type        = number
  default     = 3
  
  validation {
    condition     = var.device_count >= 1 && var.device_count <= 5
    error_message = "Device count must be between 1 and 5 for free tier limits."
  }
}