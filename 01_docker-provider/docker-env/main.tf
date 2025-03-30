resource "docker_container" "my_container" {
  image = "nginx:latest"
  name  = "my_nginx"

  # 환경 변수 설정
  env = [
    "ENVIRONMENT=production",
    "PORT=80",
    "DATABASE_URL=mysql://wp_user:wp_password@mysql_container/wordpress",
    "DEBUG=false",         # 디버그 모드 비활성화
    "API_KEY=abc123def456" # API 키 설정
  ]

  ports {
    internal = 80
    external = 8080
  }
}
