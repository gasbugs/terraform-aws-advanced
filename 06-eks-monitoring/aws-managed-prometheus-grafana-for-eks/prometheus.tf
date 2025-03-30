###################################################
# EKS 모듈 생성 후 20초 대기하는 로컬 실행 작업
resource "time_sleep" "wait_after_eks" {
  create_duration = "20s"

  depends_on = [
    null_resource.eks_kubectl_config
  ]
}

###################################################
# 네임스페이스와 IRSA 생성
# monitoring 네임스페이스 생성
resource "null_resource" "prometheus_ns" {
  provisioner "local-exec" {
    command = "kubectl apply -f prometehus-ns.yaml"
  }

  depends_on = [
    time_sleep.wait_after_eks
  ]
}

# AMP 권한을 사용하기 위해 필요한 IAM 정책 정의
data "aws_iam_policy" "amp_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

# Prometheus에 사용할 IRSA(Identity and Access Management Roles for Service Accounts) 모듈 정의
# EKS 클러스터에 Prometheus와 연동할 역할을 생성
module "irsa_prometheus" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" # IAM 모듈의 경로
  version = "5.47.1"                                                              # 모듈 버전

  create_role  = true                                          # 역할을 생성하도록 설정
  role_name    = "AmazonPrometheus-${module.eks.cluster_name}" # 역할 이름 설정
  provider_url = module.eks.oidc_provider                      # EKS OIDC 프로바이더 URL
  role_policy_arns = [
    data.aws_iam_policy.amp_policy.arn,
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:prometheus-server"] # OIDC 주체 설정
  depends_on                    = [null_resource.prometheus_ns]
}

resource "kubernetes_service_account" "amp_irsa" {
  metadata {
    name      = "prometheus-server"
    namespace = "monitoring"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_prometheus.iam_role_arn
    }
  }
  depends_on = [null_resource.prometheus_ns]
}

###################################################
# helm으로 프로메테우스 및 node-exporter 구성하기
# Helm Chart 설치
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  values = [
    templatefile("custom-values.yaml", {
      region           = var.aws_region
      remote_write_url = "${aws_prometheus_workspace.example.prometheus_endpoint}api/v1/remote_write"
    })
  ]

  depends_on = [kubernetes_service_account.amp_irsa]
}


