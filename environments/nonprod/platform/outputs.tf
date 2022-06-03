# output "azurerm_key_vault_id" {
#   value = azurerm_key_vault.kv.id
# }
output "azurerm_resource_group_name" {
    value = azurerm_resource_group.example.name
}
output "azurerm_resource_group_location" {
    value = azurerm_resource_group.example.location
}