# argocd
helm install -f ./k8s/helm-values/argocd-values.yaml argocd argo-cd/argo-cd -n argocd --create-namespace
helm install my-gateway-api oci://ghcr.io/nicklasfrahm/charts/gateway-api --version 0.2.0 -n gateway --create-namespace

# metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# kubectl rollout status deployment metrics-server -n kube-system
# kubectl top pods -A
