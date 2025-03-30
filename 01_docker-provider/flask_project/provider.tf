# terraform 설정 파일 (main.tf)

# Terraform 설정
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Docker 프로바이더 설정
provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = "registry-1.docker.io"
    username = "my-username"
    password = "*****************************"
  }
}
