resource "digitalocean_kubernetes_cluster" "scoutplan-app" {
  name    = "scoutplan-app"
  region  = "nyc3"
  version = "1.26.3-do.0"
}