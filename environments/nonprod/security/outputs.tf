# output "client_key" {
#   value = azurerm_kubernetes_cluster.main.kube_config[0].client_key
# }

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.kv.id
}
# data.azurerm_resource_group.example.name
# output "azurerm_resource_group_name" {
#     value = data.terraform_remote_state.foundation.name
    
# }
# output "azurerm_resource_group_location" {
#     value = data.terraform_remote_state.foundation.location  # data.azurerm_resource_group.example.location
# }
