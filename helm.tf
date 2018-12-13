provider "helm" {
  service_account = "tiller"
  install_tiller  = true

  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "my-database" {
  name  = "my-database"
  chart = "stable/mariadb"

  set {
    name  = "mariadbUser"
    value = "foo"
  }

  set {
    name  = "mariadbPassword"
    value = "qux"
  }
}
