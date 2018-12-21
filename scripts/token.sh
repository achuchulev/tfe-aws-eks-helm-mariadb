#!/usr/bin/env bash

set -e

exec 5>&1 &>/dev/null

# Workaround to set the helm TF provider
bash scripts/helm.sh

sudo apt-get -qq update
sudo apt-get -qq --no-install-recommends install jq

pushd /usr/local/bin

which aws-iam-authenticator || {
  # from https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
  sudo curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
  sudo chmod +x aws-iam-authenticator
}

popd

# Extract cluster name from STDIN / the query in the external data source.
eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name)"')"

# Retrieve token with AWS IAM Authenticator.
TOKEN=$(/usr/local/bin/aws-iam-authenticator token -i ${CLUSTER_NAME} | jq -r .status.token)

exec 1>&5

# Output token as JSON
jq -n --arg token "$TOKEN" '{"aws_token": $token}'
