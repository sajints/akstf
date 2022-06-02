data "azurerm_resource_group" "main" {
  name = "rgaks"
}

resource "azurerm_container_registry" "example" {
  name                  = "sajinacr"
  resource_group_name   = data.azurerm_resource_group.main.name
  location              = data.azurerm_resource_group.main.location
  sku                   = "Basic"
  admin_enabled = true
  # data_endpoint_enabled = true
}
resource "azurerm_key_vault_secret" "cr_admin_credentials" {
  #checkov:skip=CKV_AZURE_41
  #checkov:skip=CKV_AZURE_114
  name         = "cr-admin-credentials"
  value        = "${azurerm_container_registry.example.admin_username}:${azurerm_container_registry.example.admin_password}"
  key_vault_id = data.terraform_remote_state.security.outputs.azurerm_key_vault_id
}

# resource "azurerm_container_registry_token" "example" {
#   name                    = "exampletoken"
#   container_registry_name = azurerm_container_registry.example.name
#   resource_group_name     = azurerm_container_registry.example.resource_group_name
#   # scope_map_id            = azurerm_container_registry_scope_map.example.id
# }
# resource "azurerm_container_connected_registry" "example" {
#   name                  = "examplecr"
#   container_registry_id = azurerm_container_registry.example.id
#   sync_token_id         = azurerm_container_registry_token.example.id
# }