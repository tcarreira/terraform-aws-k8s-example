
terraform {
    backend "s3" {
      bucket = "terraform-aws-k8s-example"
      key    = "app-state"
      region = "eu-west-1"
    }
}
