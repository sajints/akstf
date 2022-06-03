# data "azurerm_resource_group" "main" {
#   # backend = "azurerm"
#   name = "rgaks"
# }
data "terraform_remote_state" "foundation" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rgaksstorage"
    storage_account_name = "storagetfstatesajin"
    container_name       = "nonprodtfstate"
    key                  = "foundation/terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {}

resource "random_id" "kv_id" {
  keepers = {
    # resource_group_name =  "${data.terraform_remote_state.foundation.outputs.azurerm_resource_group_name}"
    resource_group_name = "rgaks" # data.terraform_remote_state.foundation.outputs.azurerm_resource_group_name

  }

  byte_length = 8
}

resource "azurerm_key_vault" "kv" {
  name = "kv-${random_id.kv_id.hex}"
  # location            = "${data.terraform_remote_state.foundation.outputs.azurerm_resource_group_location}"
  location            = "eastus" # data.terraform_remote_state.foundation.outputs.azurerm_resource_group_location
  resource_group_name = "rgaks" # data.terraform_remote_state.foundation.outputs.azurerm_resource_group_name

  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create",
      "Delete",
      "Recover",
      "Restore",
      "Purge",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Restore",
      "Purge",
    ]
  }

  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = "ee7ec813-0563-47b6-8178-c6791b8a56ae"

  #   secret_permissions = [
  #     "Get",
  #     "List",
  #     "Set",
  #   ]
  # }

  #checkov:skip=CKV_AZURE_109
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    # virtual_network_subnet_ids = [data.azurerm_subnet.snet_aks_cluster_nodes.id]
  }

  #tags = local.tags
}
