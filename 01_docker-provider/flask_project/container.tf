resource "docker_container" "ex_container" {
  name  = "ex"
  image = docker_image.my-flask-app-2.image_id
  ports {
    internal = 8000
    external = 8000
  }
}
