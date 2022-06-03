provider "azurerm" {
  features {}
}
provider "azuread" {}

terraform {
  backend "azurerm" {
    resource_group_name  = "rgaksstorage"
    storage_account_name = "storagetfstatesajin"
    container_name       = "nonprodtfstate"
    key                  = "security/terraform.tfstate"
  }
    required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">= 2.0"
    # }
  }
}

data "terraform_remote_state" "security" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rgaksstorage"
    storage_account_name = "storagetfstatesajin"
    container_name       = "nonprodtfstate"
    key                  = "security/terraform.tfstate"
  }
}