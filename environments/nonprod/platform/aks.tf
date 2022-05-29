resource "azurerm_resource_group" "example" {
  name     = var.rgname
  location = "eastus"
}

module "network" {
  source              = "./modules/network"  # "Azure/network/azurerm" # 
  resource_group_name = azurerm_resource_group.example.name
  address_space       = "10.52.0.0/16"
  subnet_prefixes     = ["10.52.1.0/24"]
  subnet_names        = ["subnet1"]
  depends_on          = [azurerm_resource_group.example]
}

# data "azuread_group" "aks_cluster_admins" {
#   name = "AKS-cluster-admins"
# }

module "aks" {
  source                           =  "./modules/aks" # "Azure/aks/azurerm" # 
  # version                          = "4.14.0"
  resource_group_name              = azurerm_resource_group.example.name
  kubernetes_version               = var.kubernetes_version
  orchestrator_version             = var.kubernetes_version
  prefix                           = "prefix"
  cluster_name                     = "clusteraks"
  network_plugin                   = "azure"
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  os_disk_size_gb                  = 50
  sku_tier                         = "Paid" # defaults to Free
  enable_role_based_access_control = true
  rbac_aad_admin_group_object_ids  = ["2371623d-1cb4-4506-a7a0-46be7e3ad35c"]  #[data.azuread_group.aks_cluster_admins.id]
  rbac_aad_managed                 = true
  private_cluster_enabled          = true # default value
  enable_http_application_routing  = true
  enable_azure_policy              = false
  enable_auto_scaling              = true
  enable_host_encryption           = true
  enable_log_analytics_workspace   = false
  agents_min_count                 = 1
  agents_max_count                 = 1
  enable_kube_dashboard            = false 
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "nodepool"
  # agents_availability_zones        = ["1", "2"]
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
  ingress_application_gateway_subnet_cidr = "10.52.2.0/24"

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

   depends_on = [module.network]  # azurerm_virtual_network.vnet]
}

# data "azurerm_kubernetes_cluster" "dataaks" {
#   resource_group_name = azurerm_resource_group.example.name
#   name = "clusteraks" 
#   # host = data.azurerm_kubernetes_cluster.main.outputs.host
# }

module "k8s" {
  source = "./modules/k8s/"
  host = module.aks.host
  client_certificate = "${base64decode(module.aks.client_certificate)}"
  client_key = "${base64decode(module.aks.client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks.cluster_ca_certificate)}"
  kubernetes_cluster_name = "clusteraks"
  rgname = azurerm_resource_group.example.name
  depends_on          = [module.aks]
}