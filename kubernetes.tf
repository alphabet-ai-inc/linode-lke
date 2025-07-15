# Namespace for cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Secret for Docker Registry authentication
resource "kubernetes_secret" "registry_auth" {
  metadata {
    name = "regcred"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_domain}" = {
          "username" = var.registry_username
          "password" = random_password.registry_password.result
          "email"    = var.email
          "auth"     = base64encode("${var.registry_username}:${random_password.registry_password.result}")
        }
      }
    })
  }
}

# Secret fpr Object Storage keys
resource "kubernetes_secret" "registry_storage" {
  metadata {
    name = "registry-storage"
  }

  data = {
    "accesskey" = linode_object_storage_key.registry.access_key
    "secretkey" = linode_object_storage_key.registry.secret_key
  }
}

resource "local_file" "kubeconfig" {
  content  = base64decode(data.linode_lke_cluster.main.kubeconfig)
  filename = "${path.module}/kubeconfig.yaml"
}
