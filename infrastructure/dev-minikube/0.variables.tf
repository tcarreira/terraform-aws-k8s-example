
variable "cluster-name" {
  default = "minikube"
  type    = string
}

variable "POSTGRES_DB" {
  default = "postgres"
  type    = string
}
variable "POSTGRES_USER" {
  default = "postgres"
  type    = string
}
variable "POSTGRES_PASSWORD" {
  default = "postgres"
  type    = string
}

variable "domain_name" {
  default = "commentapi.dev"
  type    = string
}
