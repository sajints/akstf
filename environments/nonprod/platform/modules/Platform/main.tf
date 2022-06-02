data "azurerm_resource_group" "main" {
  name = "rgaks"
}

resource "azurerm_container_registry" "example" {
  name                  = "exampleacr"
  resource_group_name   = data.azurerm_resource_group.main.name
  location              = data.azurerm_resource_group.main.location
  sku                   = "Basic"
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