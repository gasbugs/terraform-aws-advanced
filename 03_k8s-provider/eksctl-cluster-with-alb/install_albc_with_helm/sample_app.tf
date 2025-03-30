provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Deployment 리소스
resource "kubernetes_deployment" "http_go" {
  metadata {
    name = "http-go"
    labels = {
      app = "http-go"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "http-go"
      }
    }

    template {
      metadata {
        labels = {
          app = "http-go"
        }
      }

      spec {
        container {
          image = "gasbugs/http-go:ingress"
          name  = "http-go"
        }
      }
    }
  }
}

# Service 리소스
resource "kubernetes_service" "http_go" {
  metadata {
    name = "http-go"
    labels = {
      app = "http-go"
    }
  }

  spec {
    type = "ClusterIP" # NodePort
    selector = {
      app = "http-go"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

# Ingress 리소스
resource "kubernetes_ingress_v1" "http_go_ingress" {
  depends_on = [helm_release.aws_load_balancer_controller]

  metadata {
    name = "http-go-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/target-type" = "ip" # instance
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      # 내부용 Ingress의 경우 아래 주석을 활성화
      # "alb.ingress.kubernetes.io/scheme"         = "internal"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/welcome/test"
          path_type = "Exact"

          backend {
            service {
              name = kubernetes_service.http_go.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
