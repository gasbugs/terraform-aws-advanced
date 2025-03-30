###################################################################
# AMP 생성하기
# Amazon Managed Prometheus(AMP) 워크스페이스 생성
resource "aws_prometheus_workspace" "example" {
  alias = var.prometheus_alias
  tags = {
    Name = "My Prometheus Workspace"
  }
}

###################################################################
# AMG 생성하기
# Amazon Managed Grafana(AMG) 워크스페이스 생성
resource "aws_grafana_workspace" "example" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  tags = {
    Name = "My Grafana Workspace-${random_string.suffix.result}"
  }

  role_arn = aws_iam_role.grafana_admin.arn

  data_sources              = ["PROMETHEUS"]
  notification_destinations = ["SNS"]

  configuration = jsonencode(
    {
      "plugins" = {
        "pluginAdminEnabled" = true
      },
      "unifiedAlerting" = {
        "enabled" = true
      }
    }
  )
}

# Amazon Managed Grafana(AMG) 권한 구성
resource "aws_iam_role" "grafana_admin" {
  name = "GrafanaAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_admin_attach" {
  role       = aws_iam_role.grafana_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"
}

###################################################################
# 유저 설정하기
resource "aws_grafana_role_association" "example" {
  # ADMIN | EDITOR | VIEWER
  role = "ADMIN"
  # SSO에서 사용자 설정 확인 필요
  user_ids     = ["4478a428-b071-7016-dfb5-9ccb808a2f9b"]
  workspace_id = aws_grafana_workspace.example.id
}

