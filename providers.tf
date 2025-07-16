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
  backend "s3" {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    shared_credentials_files    = ["~/.linode_credentials"]
    shared_config_files         = ["~/.linode_config"]
    profile                     = "linode"
    bucket                      = "infra-config"
    key                         = "states/linode-lke/dev/tfstate"
    region                      = "us-ord"
    endpoints = {
      s3 = "https://us-ord-1.linodeobjects.com"
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
