# ecom-app

Helm chart for the e-commerce web application. It owns only resources in the
application namespace: ConfigMap, Deployment, Service, optional HPA, optional
Secret, and optional HTTPRoute.

## Prerequisites

- Kubernetes metrics-server when autoscaling is enabled.
- Gateway API CRDs and a Gateway when `route.enabled=true`.
- A Secret containing `.env.prod` and `.env.keys`, unless `secret.create=true`.

Create the default Secret outside Helm (or use External Secrets/SOPS):

```bash
kubectl -n ecom-app create secret generic ecom-app-secret \
  --from-file=.env.prod --from-file=.env.keys
```

## Install

```bash
helm upgrade --install ecom-app ./ecom-app-chart --namespace ecom-app --create-namespace
```

To expose the application through an existing Gateway, set `route.enabled`,
`route.hostname`, `route.gatewayName`, and `route.gatewayNamespace` in an
environment-specific values file.
