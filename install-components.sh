# 1. configure the kubeconfig file for the EKS cluster
export EKS_CLUSTER_NAME=$(terraform -chdir=./infra/modules/prod output -raw cluster_name)
aws eks update-kubeconfig --profile admin-access --name $EKS_CLUSTER_NAME

# 2. install argocd: https://artifacthub.io/packages/helm/argo/argo-cd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace

# 3. install Gateway API Controller and CRDs: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/#prerequisites
kubectl apply --server-side=true -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

# 3.1. AWS LBC gateway api CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml

# 4. install AWS LBC: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/#add-controller-to-cluster
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
--set clusterName=$EKS_CLUSTER_NAME \
-n kube-system \
--set serviceAccount.name=aws-load-balancer-controller
