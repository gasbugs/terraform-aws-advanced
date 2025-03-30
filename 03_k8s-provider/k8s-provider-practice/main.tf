terraform {
  required_version = ">= 1.9.6" # Terraform 최소 요구 버전
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "${pathexpand("~")}/.kube/config"
  }
}

# Helm 차트 설치
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
