terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm  = {
      source = "hashicorp/azurerm"
      version = "3.68.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "1.7.0"
    }
  }
}

provider "azurerm" {
  features  {}
}

provider "azapi" {
}