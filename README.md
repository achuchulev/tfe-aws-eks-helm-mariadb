# This example uses Terraform Enterprise to create an AWS EKS (Kubernetes) cluster, and then uses HELM to install MariaDB chart.

***

#####  **Warning: Following this guide will create objects in your AWS account that will cost you money against your AWS bill.**  
***

### Requirements:
* AWS account

#### > Fork the repo
.
#### > [Connect the repo to a workspace in your TFE organisation using a VCS provider](https://www.terraform.io/docs/enterprise/workspaces/creating.html)
[You might need to create a VCS connection in TFE](https://www.terraform.io/docs/enterprise/vcs/github.html)
.
#### > [Setup the required TFE ENV variables](https://www.terraform.io/docs/enterprise/workspaces/variables.html)
```
(optional) TF_VAR_aws_region=us-east-1
(optional) TF_VAR_cluster_name=demo-cluster1
AWS_ACCESS_KEY_ID="<YOUR AWS ACCESS KEY>"
AWS_SECRET_ACCESS_KEY="<YOUR AWS SECRET KEY>"
```

#### > [Queue a RUN](https://www.terraform.io/docs/enterprise/run/ui.html)

The output named "kubeconfig" can be used to setup kubectl if you want to play around with eht K8S cluster.
You will need to have aws-iam-authenticator installed and set up and you would also need to allow network access from your workstation to the K8S cluster. 

#### > To destroy - set the ENV variable CONFIRM_DESTROY to 1 in TFE and queue a destroy run

Check for leftover resources in AWS. Most likely the MariaDB volumes will still be there.

#### > Notes:
The AWS IAM Token is generated in the beginning of the run, but has an expiry time of 15 minutes.
If that is not enough for all operations on AWS, the run will fail, but a subsequent run should complete successfully.
Currently there expiry time seems to be fixed, and a different approach might be needed if this is an issue.

The helm provider currently requires files on disk (repository list and cache) to operate correctly.
This is an issue with TFE, since no files are persisted between operations, so a workaround is used.

This is only a PoC. 
For production, proper K8S RBAC should be implemented, and the code could be split into different workspaces (EKS setup, helm, etc.)
