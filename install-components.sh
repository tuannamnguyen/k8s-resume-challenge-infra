# 1. configure the kubeconfig file for the EKS cluster
export EKS_CLUSTER_NAME=$(terraform -chdir=./infra/environments/prod output -raw cluster_name)
aws eks update-kubeconfig --profile admin-access --name $EKS_CLUSTER_NAME

# 2. install argocd: https://artifacthub.io/packages/helm/argo/argo-cd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace

# 3. install Gateway API Controller and CRDs: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/#prerequisites
kubectl apply --server-side=true -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

# 3.1. AWS LBC gateway api CRDs. note: no need to install the CRDs if you are using the helm chart for AWS LBC
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml

# 4. install AWS LBC: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/#add-controller-to-cluster
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=k8s-resume-challenge-prod \
  -n kube-system \
  --set serviceAccount.name=aws-load-balancer-controller \
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/#using-the-amazon-ec2-instance-metadata-server-version-2-imdsv2
  --set vpcId=$(terraform -chdir=./infra/environments/prod output -raw vpc_id) \
  --set region=$(terraform -chdir=./infra/environments/prod output -raw aws_region) \
  --skip-crds # apply if you have applied the CRDs in step 3.1

# 5. apply helm chart for gateway resources:
