# 1. configure the kubeconfig file for the EKS cluster
export EKS_CLUSTER_NAME=$(terraform -chdir=./infra/modules/prod output -raw cluster_name)
aws eks update-kubeconfig --profile admin-access --name $EKS_CLUSTER_NAME

# 2. install argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace

# 3. install Gateway controller
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.0/standard-install.yaml
