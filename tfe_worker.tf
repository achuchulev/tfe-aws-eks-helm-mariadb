resource "null_resource" "local_install" {
  depends_on = ["aws_eks_cluster.demo"]

  provisioner "local-exec" {
    command = "bash ${path.module}/provision_tfe_worker.sh"
  }

  triggers {
    timestamp = "${timestamp()}"
  }
}

resource "null_resource" "local_install_on_destroy" {
  depends_on = ["aws_eks_cluster.demo", null_resource.local_install]

#  provisioner "local-exec" {
#    command = "bash ${path.module}/profivion_tfe_worker.sh"
#    when    = "destroy"
#  }
}

