#!/usr/bin/env bash

# Install kubectl and aws-iam-authenticator

pushd /usr/local/bin

which kubectl || {
  # from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#install-kubectl-linux
  sudo curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
  sudo chmod +x kubectl
}

which aws-iam-authenticator || {
  # from https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
  sudo curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
  sudo chmod +x aws-iam-authenticator
}

popd

# Configure kubectl

mkdir -p ~/.kube
terraform output kubeconfig > ~/.kube/config

# Debug - see if it's working

kubectl version

# Install Helm

pushd $(mktemp -d)
pwd
curl -o helm-get.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get
chmod +x helm-get.sh
./helm-get.sh -v latest
popd

# Allow nodes to join the cluster
# (This needs to be run only once, so maybe move it to another script)

terraform output config_map_aws_auth > config_map_aws_auth.yaml
kubectl apply -f config_map_aws_auth.yaml
kubectl get nodes

# Debug - make sure we have a default storage class set

kubectl get sc

# TODO - This should be moved to the TF code. An ugly workaround is used since it fails after the initial creation
# Create a service account for Tiller
kubectl create serviceaccount --namespace kube-system tiller ; true
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller ; true

# Install and initialize Helm
helm init --service-account tiller --wait

kubectl get all --all-namespaces

ls -la ~/.kube/config

kubectl config use-context default-system

