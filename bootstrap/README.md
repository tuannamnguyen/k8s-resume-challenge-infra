# Argo CD bootstrap

These manifests are intentionally outside application charts. Apply them once
after Argo CD itself has been installed, rather than making an Argo Application
manage the chart that defines that same Application.

```bash
kubectl apply -f bootstrap/argocd/applications/ecom-app.yaml
```

The Application syncs only `ecom-app-chart` into the `ecom-app` namespace. The
shared Gateway resources belong to `gateway-platform-chart` and should be
managed by a separate platform release or Argo CD Application.
