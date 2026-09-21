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
        repositories = {
          k8s-resume-challenge-argocd = {
            url = "https://github.com/tuannamnguyen/k8s-resume-challenge-argocd"
          }
        }
        credentialTemplates = {
          https-creds = {
            url      = "https://github.com/tuannamnguyen"
            username = var.github_user
            password = var.github_password
          }
        }
      }
    })
  ]

  depends_on = [module.eks]
}

resource "helm_release" "argocd_apps" {
  count      = var.create_argocd ? 1 : 0
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  name       = "argocd-apps"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        bootstrap-app = {
          project = "default"
          source = {
            repoURL        = "https://github.com/tuannamnguyen/k8s-resume-challenge-argocd.git"
            targetRevision = "main"
            path           = "bootstrap"

            helm = {
              version = "v3"
              valuesObject = {
                valuesFromTerraform = {
                  vpcId = var.vpc_id
                }
              }
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
          }
          syncPolicy = {
            automated = {
              prune    = false
              selfHeal = false
            }
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}
