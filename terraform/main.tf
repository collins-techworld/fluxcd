resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  chart            = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator"
  namespace        = "flux-system"
  create_namespace = true
}

resource "kubernetes_secret" "flux_git_secret" {
  metadata {
    name      = var.secret_name
    namespace = "flux-system"
  }

  type = "Opaque"

  data = {
    username = base64encode("git")
    password = base64encode(var.github_token)
    url      = base64encode(var.github_url)
  }
}

resource "kubernetes_manifest" "flux_instance" {
  manifest = {
    apiVersion = "fluxcd.controlplane.io/v1"
    kind       = "FluxInstance"
    metadata = {
      name      = "flux"
      namespace = "flux-system"
      annotations = {
        "fluxcd.controlplane.io/reconcileEvery"  = "1h"
        "fluxcd.controlplane.io/reconcileTimeout" = "5m"
      }
    }
    spec = {
      distribution = {
        version  = "2.x"
        registry = "ghcr.io/fluxcd"
        artifact = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
      }

      components = [
        "source-controller",
        "kustomize-controller",
        "helm-controller",
        "notification-controller",
        "image-reflector-controller",
        "image-automation-controller"
      ]

      cluster = {
        type         = "kubernetes"
        size         = "medium"
        multitenant  = false
        networkPolicy = true
        domain        = "cluster.local"
      }

      kustomize = {
        patches = [
          {
            target = {
              kind = "Deployment"
            }
            patch = <<-EOF
              - op: replace
                path: /spec/template/spec/nodeSelector
                value:
                  kubernetes.io/os: linux
              - op: add
                path: /spec/template/spec/tolerations
                value:
                  - key: "CriticalAddonsOnly"
                    operator: "Exists"
            EOF
          }
        ]
      }

      sync = {
        kind  = "GitRepository"
        url   = var.github_url
        ref   = "refs/heads/main"
        path  = "clusters/staging"
        pullSecret = var.secret_name
      }
    }
  }

  depends_on = [
    helm_release.flux_operator,
    kubernetes_secret.flux_git_secret
  ]
}
