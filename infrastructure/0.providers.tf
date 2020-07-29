provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}


# also, you may execute: aws eks update-kubeconfig --name terraform-eks
provider "kubernetes" {
  host                   = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

provider "http" {}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks-cluster.id
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

