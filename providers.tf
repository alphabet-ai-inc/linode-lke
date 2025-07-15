# https://registry.terraform.io/providers/linode/linode/latest/docs
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.40.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.0"
    }
  }
}

provider "linode" {
  token = trimspace(file("~/.linode_token"))
}

data "linode_lke_cluster" "main" {
  id = linode_lke_cluster.main.id
}

locals {
  kubeconfig = yamldecode(base64decode(data.linode_lke_cluster.main.kubeconfig))
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  token                  = local.kubeconfig.users[0].user.token
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    token                  = local.kubeconfig.users[0].user.token
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  }
}
provider "htpasswd" {}
