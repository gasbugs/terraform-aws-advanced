# 볼륨 생성
resource "docker_volume" "db_data" {
  name   = "db_data"
  driver = "local" # 로컬 볼륨 드라이버 사용
}

# MySQL 컨테이너 생성 및 볼륨 마운트
resource "docker_container" "mysql_container" {
  image = "mysql:5.7"
  name  = "mysql_db"

  env = [
    "MYSQL_ROOT_PASSWORD=rootpassword",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wp_user",
    "MYSQL_PASSWORD=wp_password"
  ]

  # 볼륨 마운트
  mounts {
    target    = "/var/lib/mysql"           # 컨테이너 내부의 MySQL 데이터 디렉터리
    source    = docker_volume.db_data.name # 테라폼으로 생성한 볼륨 마운트
    type      = "volume"
    read_only = false # 읽기 및 쓰기 가능
  }

  ports {
    internal = 3306
    external = 3306
  }
}
