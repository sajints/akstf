resource "azurerm_resource_group" "example" {
  name     = var.rgname
  location = "eastus"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]
  depends_on          = [azurerm_resource_group.example]
}

data "azuread_client_config" "aks_cluster_admins" {}

resource "azuread_user" "group_owner" {
  user_principal_name = "sajints@outlook.com"
  display_name        = "aks_cluster_admins"
  mail_nickname       = "example-group-owner"
  password            = "SecretP@sswd99!"
}

# data "azuread_group" "aks_cluster_admins" {
#   # object_id =  "e6d277c0-4e7f-4eab-9745-3acf027afb47"
#   owners           = [data.azuread_client_config.aks_cluster_admins.object_id]
#   display_name = "AKS-cluster-admins"
# }

module "aks" {
  source                           = "Azure/aks/azurerm"
  version                          = "4.14.0"
  resource_group_name              = azurerm_resource_group.example.name
  kubernetes_version               = var.kubernetes_version
  orchestrator_version             = var.kubernetes_version
  prefix                           = "prefix"
  cluster_name                     = "clusterwithtf"
  network_plugin                   = "azure"
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  os_disk_size_gb                  = 50
  sku_tier                         = "Paid" # defaults to Free
  enable_role_based_access_control = true
  # rbac_aad_admin_group_object_ids  = [data.azuread_group.aks_cluster_admins.object_id]
  rbac_aad_managed                 = true
  private_cluster_enabled          = true # default value
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = true
  enable_host_encryption           = true
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "systemnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  # ingress_application_gateway {
  #   enabled    = true
  #   gateway_id = azurerm_application_gateway.agw.id
  # }

  enable_ingress_application_gateway = true
  ingress_application_gateway_name = "aks-agw"
  ingress_application_gateway_subnet_cidr = "10.52.1.0/24"

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed = true
      admin_group_object_ids = [
        "e6d277c0-4e7f-4eab-9745-3acf027afb47", # C-CT-prod-css-admin
      ]
    }
  }

  depends_on = [module.network]
}
