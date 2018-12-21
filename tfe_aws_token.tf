# Generate an AWS token
data "external" "aws_iam_authenticator_token" {
  #   depends_on = ["aws_eks_cluster.demo", "aws_autoscaling_group.demo"]
  program = ["bash", "${path.module}/scripts/token.sh"]

  query {
    cluster_name = "${var.cluster_name}"
  }
}
