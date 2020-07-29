
resource "kubernetes_ingress" "commentapi" {
  metadata {
    name      = "commentapi"
    namespace = "commentapi"
  }

  wait_for_load_balancer = false

  spec {
    backend {
      service_name = "commentapi"
      service_port = 80
    }

    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service_name = "commentapi"
            service_port = 80
          }

          path = "/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}
