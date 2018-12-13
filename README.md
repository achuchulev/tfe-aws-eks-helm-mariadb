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
(optional) TF_VAR_eks_worker_instance_type=t2.small  # depends on intended workload
(optional) TF_VAR_eks_worker_desired_capacity=1      # depends on intended workload
(optional) TF_VAR_aws_region=us-east-1
(optional) TF_VAR_cluster_name=demo-cluster1
AWS_ACCESS_KEY_ID="<YOUR AWS ACCESS KEY>"
AWS_SECRET_ACCESS_KEY="<YOUR AWS SECRET KEY>"
```

#### > [Queue a RUN](https://www.terraform.io/docs/enterprise/run/ui.html)

#### > To destroy - set the ENV variable CONFIRM_DESTROY to 1 in TFE and queue a destroy run
