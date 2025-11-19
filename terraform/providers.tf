terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
  #   kubernetes-alpha = {
  #     source  = "hashicorp/kubernetes-alpha"
  #     version = ">= 0.6.0"
  #  }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-flux"
}

# provider "kubernetes-alpha" {
#   config_path    = "~/.kube/config"
#   config_context = "kind-flux"
# }

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-flux"
  }
}
