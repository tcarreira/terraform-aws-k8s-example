resource "kubernetes_secret" "database-secret" {
  metadata {
    name      = "database-secret"
    namespace = "commentapi"
  }

  data = {
    DATABASE_URL      = "postgres://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@postgres:5432/${var.POSTGRES_DB}?sslmode=disable"
    POSTGRES_HOST     = "postgres"
    POSTGRES_PORT     = "5432"
    POSTGRES_DB       = var.POSTGRES_DB
    POSTGRES_USER     = var.POSTGRES_USER
    POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
  }
}

resource "kubernetes_service" "commentapi" {
  metadata {
    name        = "commentapi"
    namespace   = "commentapi"
    annotations = {}
  }
}
