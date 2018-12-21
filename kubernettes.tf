provider "kubernetes" {
  host                   = "${aws_eks_cluster.demo.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
  token                  = "${data.external.aws_iam_authenticator_token.result.aws_token}"
  load_config_file       = false
}

resource "kubernetes_config_map" "aws_auth" {
  depends_on = ["null_resource.wait_for_eks"]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.demo-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
}

# Workaround to wait for nodes to join the K8S cluster
resource "null_resource" "wait_for_nodes_to_join" {
  depends_on = ["kubernetes_config_map.aws_auth"]

  provisioner "local-exec" {
    command = "sleep 1m"
  }
}

# Workaround to wait for the EKS cluster control plane to become ready to accept communication
resource "null_resource" "wait_for_eks" {
  depends_on = ["aws_eks_cluster.demo"]

  provisioner "local-exec" {
    command = "sleep 2m"
  }
}

# Creates a SA for Tiller
resource "kubernetes_service_account" "tiller" {
  depends_on = ["null_resource.wait_for_eks"]

  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

# Gives Tiller some Admin rights - for development only, use proper RBAC in production
resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = ["kubernetes_service_account.tiller"]

  metadata {
    name = "tiller-cluster-role"
  }

  role_ref {
    #        api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }

  subject {
    api_group = ""

    #    api_group = "rbac.authorization.k8s.io"
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }

  lifecycle {
    ignore_changes = ["role_ref.%", "role_ref.api_group"]
  }
}
