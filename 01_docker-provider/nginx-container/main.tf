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
}

# 도커 이미지 가져오기
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# 도커 컨테이너 설정 및 배포
resource "docker_container" "nginx_container" {
  image = docker_image.nginx.image_id
  name  = "my-nginx"

  # 포트 매핑 (호스트의 8080 포트를 컨테이너의 80 포트에 연결)
  ports {
    internal = 80
    external = 8080
  }

  # 컨테이너 자동 재시작 설정
  restart = "always"
}
