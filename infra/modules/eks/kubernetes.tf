resource "kubernetes_secret_v1" "grafana_admin_password" {
  metadata {
    name      = "grafana-admin-password"
    namespace = "monitoring"
  }

  data = {
    grafana_admin_user     = var.grafana_admin_user
    grafana_admin_password = var.grafana_admin_password
  }

  depends_on = [module.eks]
}
