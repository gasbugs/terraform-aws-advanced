# 도커 브리지 네트워크 생성
resource "docker_network" "app_network" {
  name   = "app_network"
  driver = "bridge"
}

# 첫 번째 컨테이너 (nginx)
resource "docker_container" "nginx" {
  image = "nginx:latest"
  name  = "nginx_server"

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = 8080
  }
}

# 두 번째 컨테이너 (MySQL)
resource "docker_container" "mysql" {
  image = "mysql:latest"
  name  = "mysql_db"

  env = [
    "MYSQL_ROOT_PASSWORD=mypassword"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 3306
    external = 3306
  }
}
