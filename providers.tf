# https://registry.terraform.io/providers/linode/linode/latest/docs
terraform {
  required_version = "~> 1.12"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.40.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 5.1"
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
  id         = linode_lke_cluster.main.id
  depends_on = [linode_lke_cluster.main]
}
locals {
  tokens = fileexists("~/.vault_tokens") ? yamldecode(file("~/.vault_tokens"))["tokens"] : {}
}

provider "vault" {
  address          = var.vault_url
  token            = local.tokens[var.env][var.server_group_name]
  skip_child_token = true
}