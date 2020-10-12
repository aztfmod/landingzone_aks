landingzone_name = "101-single-cluster_argocd"

remote_tfstate = "101-single-cluster_landingzone_aks.tfstate"
cluster_key = "cluster_rg1"

namespaces = {
  fluxcd = {
    name = "argocd"
  }
}

helm_charts = {
  argocd = {
    name = "argo"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    namespace  = "argocd"
  }
}