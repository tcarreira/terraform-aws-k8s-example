
resource "aws_acm_certificate" "commentapi_ssl_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    App = "CommentAPI"
  }

  lifecycle {
    create_before_destroy = true
  }
}