#!/bin/bash
REPO_KEY=~/.ssh/argocd.pem
REPO=git@github.com:kuznetsov17/lab-app.git
ARGOCD_OPTS=--grpc-web

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 10 # service botstrap
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"},"annotations": {"service.beta.kubernetes.io/aws-load-balancer-extra-security-groups": "sg-08e08db5bb37bda29"}}'

ARGO_PSW=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
ARGO_SERVER=$(kubectl get svc argocd-server -nargocd -ojson|jq -r .status.loadBalancer.ingress|jq -r '.[]'.hostname)
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

#sleep 30 # DNS update

argocd login ${ARGO_SERVER} --username admin --password ${ARGO_PSW} --insecure
ARGO_SERVER_URL=$(argocd cluster list -ojson|jq -r '.[]'.server)
argocd repo add ${REPO}  --ssh-private-key-path ${REPO_KEY}

argocd app create demo-app --repo ${REPO} --path manifests --dest-server ${ARGO_SERVER_URL} --dest-namespace default
argocd app sync demo-app
