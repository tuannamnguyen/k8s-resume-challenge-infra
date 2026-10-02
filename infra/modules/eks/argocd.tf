resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.eks]

  create_duration = "30s"
}

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

  depends_on = [time_sleep.wait_30_seconds]
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
                  aws-load-balancer-controller = {
                    vpcId       = var.vpc_id
                    clusterName = module.eks.cluster_name
                    region      = "ap-southeast-1"

                    serviceAccount = {
                      name = "aws-load-balancer-controller"
                    }
                  }
                  argo-cd = {
                    configs = {
                      secret = {
                        argocdServerAdminPassword = var.argocd_password
                      }
                    }
                    server = {
                      ingress = {
                        annotations = {
                          "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
                        }
                      }
                    }
                  }
                  karpenter = {
                    settings = {
                      clusterName     = module.eks.cluster_name
                      clusterEndpoint = module.eks.cluster_endpoint
                      eksControlPlane = true
                    }
                  }
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
