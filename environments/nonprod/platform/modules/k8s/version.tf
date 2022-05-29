provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
        
    }
  }
}

provider "kubernetes" {
  # config_path    = "~/.kube/config"
  host = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host

  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)

  # client_certificate = "${base64decode(module.aks.client_certificate)}"
  # client_key = "${base64decode(module.aks.client_key)}"
  # cluster_ca_certificate = "${base64decode(module.aks.cluster_ca_certificate)}"
# #   config_context = "my-context"
    # load_config_file = false
    # host = var.host
    # client_certificate = var.client_certificate
    # client_key = var.client_key
    # cluster_ca_certificate = var.cluster_ca_certificate
}