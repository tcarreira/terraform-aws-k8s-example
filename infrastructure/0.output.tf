output "cert" {
  value = aws_acm_certificate.commentapi_ssl_cert
}

output "service" {
  value = kubernetes_service.commentapi
}