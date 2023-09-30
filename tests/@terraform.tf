terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  subscription_id            = local.config.azure.subscription
  skip_provider_registration = true
  features {
    key_vault {
      recover_soft_deleted_key_vaults = false
    }
  }
}
