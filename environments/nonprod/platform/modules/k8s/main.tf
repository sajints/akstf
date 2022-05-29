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

data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rgaksstorage"
    storage_account_name = "storagetfstatesajin"
    container_name       = "nonprodtfstate"
    key                  = "foundation/terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = "clusteraks" # var.kubernetes_cluster_name # data.terraform_remote_state.aks.outputs
  resource_group_name = var.rgname # data.terraform_remote_state.aks.outputs
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

# resource "kubernetes_namespace" "example" {
#   metadata {
#     name = "test"
#   }
# }

resource "kubernetes_deployment" "example" {

    metadata {
      name = "terraform-example"
      labels = {
          test = "MyExampleApp"
      }
    }
    spec {
      replicas = 1
      selector{
          match_labels = {
              test = "MyExampleApp"
          }
    }
    
    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "example"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
      }
    }
    }
}
}

resource "kubernetes_service" "svc" {
    metadata {
      name = "svc"
    }
    spec {
      selector = {
          test = "MyExampleApp"
      }
      port {
        port = 80
        target_port = 80
      }
      type = "LoadBalancer"
    }
  
}

