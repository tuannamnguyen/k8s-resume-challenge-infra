resource "helm_release" "argocd" {
  count            = var.create_argocd ? 1 : 0
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      configs = {
        params = {
          server = {
            insecure = true
          }
        }
      }
    })
  ]
}
