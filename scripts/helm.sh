#!/usr/bin/env bash

set -e

exec 5>&1 &>/dev/null

# Install Helm

tmp_helm_dir=$(mktemp -d)
pushd $tmp_helm_dir

which helm || {
  curl -o helm-get.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get
  chmod +x helm-get.sh
  ./helm-get.sh -v latest
}

popd
rm -rf $tmp_helm_dir

# Install and initialize Helm
helm init --client-only

exec 1>&5

# Currently cannot be used with TFE
# Workaround that creates helm configuration to be used with the helm TF provider
#mkdir -p /home/terraform/.helm/repository/cache
#echo "apiVersion: v1" > /home/terraform/.helm/repository/repositories.yaml
