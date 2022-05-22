# provider "kubernetes" {
# #   config_path    = "~/.kube/config"
# #   config_context = "my-context"
#     load_config_file = "false"
#     host = var.host
#     client_certificate = var.client_certificate
#     client_key = var.client_key
#     cluster_ca_certificate = var.cluster_ca_certificate
# }

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

