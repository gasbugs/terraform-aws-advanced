# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}



# Prometheus 및 Grafana 설정이 완료된 후 중요한 정보를 출력합니다.
output "prometheus_workspace_id" {
  description = "AMP workspace ID"
  value       = aws_prometheus_workspace.example.id
}

output "grafana_workspace_url" {
  description = "Grafana workspace URL"
  value       = aws_grafana_workspace.example.endpoint
}

output "prometheus_endpoint" {
  description = "Prometheus Endpoint"
  value       = aws_prometheus_workspace.example.prometheus_endpoint
}
