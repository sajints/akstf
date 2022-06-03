# data "azurerm_resource_group" "main" {
#   name = "rgaks"
# }

# data "terraform_remote_state" "security" {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "rgaksstorage"
#     storage_account_name = "storagetfstatesajin"
#     container_name       = "nonprodtfstate"
#     key                  = "security/terraform.tfstate"
#   }
# }

resource "azurerm_container_registry" "example" {
  name                  = "sajinacr"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  sku                   = "Basic"
  admin_enabled = true
  # data_endpoint_enabled = true
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