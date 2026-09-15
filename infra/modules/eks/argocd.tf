resource "helm_release" "argocd" {
  count      = var.create ? 1 : 0
  chart      = "argo/argocd"
  repository = "https://argoproj.github.io/argo-helm"
  name       = "argocd"

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
