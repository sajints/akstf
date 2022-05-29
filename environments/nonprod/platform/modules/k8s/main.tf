data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rgaksstorage"
    storage_account_name = "storagetfstatesajin"
    container_name       = "nonprodtfstate"
    key                  = "foundation/terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = "clusteraks" # var.kubernetes_cluster_name # data.terraform_remote_state.aks.outputs
  resource_group_name = var.rgname # data.terraform_remote_state.aks.outputs
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

