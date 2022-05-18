variable "name" {
  description = "The name of this nginx ingress controller"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_ingress_controller_image" {
  description = "The image to use for the NGINX ingress controller. See https://github.com/kubernetes/ingress-nginx/releases for available versions"
  type        = string
  default     = "k8s.gcr.io/ingress-nginx/controller"
}

variable "nginx_ingress_controller_image_tag" {
  description = "The image tag to use for the NGINX ingress controller. See https://github.com/kubernetes/ingress-nginx/releases for available versions"
  type        = string
  default     = "v0.44.0@sha256:3dd0fac48073beaca2d67a78c746c7593f9c575168a17139a9955a82c63c4b9a"
}

variable "nginx_config" {
  description = "Data in the k8s config map. See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap for options"
  default     = {}
}

variable "lb_annotations" {
  description = "Annotations to add to the loadbalancer"
  type        = map(string)
  default = {
    "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  }
}

variable "load_balancer_source_ranges" {
  description = "The ip whitelist that is allowed to access the load balancer"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "lb_ports" {
  description = "Load balancer port configuration"
  type = list(object({
    name        = string
    port        = number
    target_port = string
  }))
  default = [{
    name        = "http"
    port        = 80
    target_port = "http"
    }, {
    name        = "https"
    port        = 443
    target_port = "https"
  }]
}

variable "priority_class_name" {
  description = "The priority class to attach to the deployment"
  type        = string
  default     = null
}

variable "controller_replicas" {
  description = "Desired number of replicas of the nginx ingress controller pod"
  type        = number
  default     = 1
}

variable "disruption_budget_max_unavailable" {
  description = "The maximum unavailability of the nginx deployment"
  type        = string
  default     = "50%"
}


// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/mandatory.yaml
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "${var.name}-config-map"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = var.nginx_config
}

resource "kubernetes_config_map" "nginx_tcp" {
  metadata {
    name      = "${var.name}-tcp-services"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_config_map" "nginx_udp" {
  metadata {
    name      = "${var.name}-udp-services"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name      = "${var.name}-serviceaccount"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "nginx" {
  metadata {
    name = "${var.name}-clusterrole"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}

resource "kubernetes_role" "nginx" {
  metadata {
    name      = "${var.name}-role"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["${var.name}-leader"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "nginx" {
  metadata {
    name      = "${var.name}-role-binding"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.nginx.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx.metadata.0.name
    namespace = kubernetes_service_account.nginx.metadata.0.namespace
  }
}

resource "kubernetes_cluster_role_binding" "nginx" {
  metadata {
    name = "${var.name}-clusterrole-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx.metadata.0.name
    namespace = kubernetes_service_account.nginx.metadata.0.namespace
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "${var.name}-deployment"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = var.name
      "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
      // Get rid of sha digest if exists in the tag
      "app.kubernetes.io/version"    = "${element(split("@", var.nginx_ingress_controller_image_tag), 0)}"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = var.controller_replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name"    = var.name
        "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = var.name
          "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
          // Get rid of sha digest if exists in the tag
          "app.kubernetes.io/version" = "${element(split("@", var.nginx_ingress_controller_image_tag), 0)}"
        }

        annotations = {
          "prometheus.io/port"   = "10254"
          "prometheus.io/scrape" = "true"
          // TODO make these configurable
          "nginx.ingress.kubernetes.io/server-snippet" = "grpc_read_timeout 3600s;"
        }
      }

      spec {
        // wait up to 5 minutes to drain connections
        termination_grace_period_seconds = 300
        service_account_name             = kubernetes_service_account.nginx.metadata.0.name
        priority_class_name              = var.priority_class_name

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name  = "nginx-ingress-controller"
          image = "${var.nginx_ingress_controller_image}:${var.nginx_ingress_controller_image_tag}"

          args = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/${kubernetes_config_map.nginx_config.metadata.0.name}",
            "--tcp-services-configmap=$(POD_NAMESPACE)/${kubernetes_config_map.nginx_tcp.metadata.0.name}",
            "--udp-services-configmap=$(POD_NAMESPACE)/${kubernetes_config_map.nginx_udp.metadata.0.name}",
            "--publish-service=$(POD_NAMESPACE)/${var.name}",
            "--annotations-prefix=nginx.ingress.kubernetes.io",
            "--enable-ssl-chain-completion=true",
            "--election-id=${var.name}-leader",
            "--ingress-class=${var.name}",
          ]

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.nginx.default_secret_name
            read_only  = true
          }

          security_context {
            allow_privilege_escalation = true
            run_as_user                = 101
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            protocol       = "TCP"
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 10
            success_threshold     = 1
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            period_seconds    = 10
            timeout_seconds   = 10
            success_threshold = 1
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
        }

        volume {
          name = kubernetes_service_account.nginx.default_secret_name

          secret {
            secret_name = kubernetes_service_account.nginx.default_secret_name
          }
        }
      }
    }
  }
}

resource "kubernetes_limit_range" "nginx" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    limit {
      type = "Container"
      min = {
        "memory" = "90Mi"
        "cpu"    = "100m"
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget" "nginx" {
  count = var.controller_replicas > 1 ? 1 : 0
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }
  spec {
    max_unavailable = var.disruption_budget_max_unavailable
    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.name
      }
    }
  }
}

// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/provider/aws/service-nlb.yaml
resource "kubernetes_service" "lb" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = var.lb_annotations
  }

  spec {
    type = "LoadBalancer"
    selector = {
      "app.kubernetes.io/name"    = var.name
      "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
    }

    external_traffic_policy = "Local"

    dynamic "port" {
      for_each = var.lb_ports

      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }
    load_balancer_source_ranges = var.load_balancer_source_ranges
  }
}

