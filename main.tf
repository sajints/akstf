provider "azurerm" {
  features {}
}

terraform {
    required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3.0"
    }
  }
}