resource "kubernetes_namespace" "commentapi" {
  metadata {
    annotations = {
      name = "commentapi"
    }
    name = "commentapi"
  }
}

resource "kubernetes_secret" "database-secret" {
  metadata {
    name      = "database-secret"
    namespace = "commentapi"
  }

  data = {
    DATABASE_URL      = "postgres://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@${aws_db_instance.commentapi.address}:5432/${var.POSTGRES_DB}?sslmode=disable"
    POSTGRES_HOST     = aws_db_instance.commentapi.address
    POSTGRES_PORT     = "5432"
    POSTGRES_DB       = var.POSTGRES_DB
    POSTGRES_USER     = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
  }
}


resource "kubernetes_deployment" "commentapi" {
  metadata {
    name      = "commentapi"
    namespace = "commentapi"
    labels    = {
      App = "CommentAPI"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "CommentAPI"
      }
    }
    template {
      metadata {
        labels = {
          App = "CommentAPI"
        }
      }
      spec {
        container {
          image   = "tcarreira/commentapi:latest"
          name    = "commentapi"
          command = ["/bin/sh", "-c", "/bin/app migrate; /bin/app"] # TODO: wait for DB ready

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "database-secret"
                key  = "DATABASE_URL"
              }
            }
          }

          port {
            container_port = 3000
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "commentapi" {
  metadata {
    name        = "commentapi"
    namespace   = "commentapi"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"               = aws_acm_certificate.commentapi_ssl_cert.id
      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" = "ELBSecurityPolicy-TLS-1-2-2017-01"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"       = "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"              = "https"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      App = "CommentAPI"
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 3000
      protocol    = "TCP"
    }

  }
}

