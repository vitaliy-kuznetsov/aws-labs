# EKS + HELM + ArgoCD 

The provided code deploys EKS cluster in AWS account with 2 Nodes (t3.small or t2.small, SPOT).
The application is deployed to cluster using ArgoCD


- **terraform** – Contains tf template. Creates VPC, EKS cluster etc.
- **manifests** – contains deployment and service manifests, pulled by Argocd
- **argocd** – contains bash script that installs argocd aand set-up the repo

## Prerequisites
You will need to have the following components installed:
terraform 0.13+
jq
kubectl

You should have active AWS profile with relevant permissions to set-up the app.

## Flow
1. Configure the deployment in locals.tf
2. Deploy the terraform template:

`terraform init && terraform apply`

3. Set-up argocd:

`bash ./argocd/argo.sh`

ArgoCD will deploy the manifests to created cluster.
