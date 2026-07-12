# gateway-platform

Optional chart for the shared Gateway API resources. All resources are disabled
by default because Gateway API CRDs, namespaces, TLS Secrets, and the selected
Gateway controller must be installed first.

Do not create a GatewayClass with a placeholder controller name. Set
`gatewayClass.controllerName` to the exact controller name documented by the
installed Gateway controller. The controller's own Helm chart should normally
own its ServiceAccount; enable `serviceAccount.create` only when its
installation documentation requires that arrangement.
