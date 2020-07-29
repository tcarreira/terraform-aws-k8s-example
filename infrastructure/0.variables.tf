
variable "cluster-name" {
  default = "terraform-eks"
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
  type = string
}

variable "domain_name" {
  default = "commentapi.example.com"
  type    = string
}
