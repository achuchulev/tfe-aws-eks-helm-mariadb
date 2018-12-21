provider "helm" {
  service_account = "tiller"
  install_tiller  = true

  kubernetes {
    host                   = "${aws_eks_cluster.demo.endpoint}"
    cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
    token                  = "${data.external.aws_iam_authenticator_token.result.aws_token}"
  }
}

# Workaround to configure helm
resource "null_resource" "helm_config" {
  depends_on = ["data.external.aws_iam_authenticator_token", "kubernetes_cluster_role_binding.tiller", "null_resource.wait_for_nodes_to_join"]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/helm.sh"
  }

  triggers {
    timestamp = "${timestamp()}"
  }
}

# This cannot (yet) be used with TFE due to files not persisting on the worker
/*
resource "helm_repository" "stable" {
  depends_on = ["null_resource.helm_config"]

  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}
*/

resource "helm_release" "my-database" {
  depends_on = ["null_resource.helm_config"]

  # Timeout (in seconds) - Needed, as MariaDB is not able to start in the default 5 minutes
  timeout = "900"

  name  = "my-database"
  chart = "mariadb"

  #  repository = "${helm_repository.stable.metadata.0.name}"
  repository = "stable"

  set {
    name  = "mariadbUser"
    value = "foo"
  }

  set {
    name  = "mariadbPassword"
    value = "qux"
  }
}
