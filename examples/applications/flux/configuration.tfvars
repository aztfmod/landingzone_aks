landingzone_name = "101-single-cluster_dapr"

remote_tfstate = "101-single-cluster_landingzone_aks.tfstate"
cluster_key = "cluster_rg1"

namespaces = {
  fluxcd = {
    name = "fluxcd"
    annotations = {
      name = "flux-annotation"
    }
    labels = {
      mylabel = "flux-value"
    }
  }
}

helm_charts = {
  # dapr = {
  #   name = "dapr"
  #   repository = "https://daprio.azurecr.io/helm/v1/repo"
  #   chart      = "dapr"
  #   namespace  = "default"
  # }
  flux = {
    name = "flux"
    repository = "https://charts.fluxcd.io"
    chart      = "flux"
    namespace  = "fluxcd"
  }
  flux_helm_operator = {
    name = "helm-operator"
    repository = "https://charts.fluxcd.io"
    chart      = "helm-operator"
    namespace  = "fluxcd"
    sets = {
      "git.ssh.secretName" = "flux-git-deploy"
      "helm.versions" = "v3"
    }
  }
}