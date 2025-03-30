variable "aws_region" {
  type    = string
  default = "us-east-1"
}


# AMP의 에일리어스를 변수로 받습니다.
variable "prometheus_alias" {
  description = "Prometheus workspace alias"
  type        = string
  default     = "my-prometheus"
}
