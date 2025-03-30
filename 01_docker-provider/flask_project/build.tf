# docker_image: 풀링 및 빌드하는 기능  
resource "docker_image" "my-flask-app-2" {
  name = "registry-1.docker.io/myusername/my-flask-app-2"
  build {
    context = "./Dockerfile"
  }
}

# docker_registry_image: 푸시하는 기능 
resource "docker_registry_image" "my-flask-app-2" {
  name          = docker_image.my-flask-app-2.name
  keep_remotely = true
}
