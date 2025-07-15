# Random password
resource "random_password" "registry_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*"
}

# NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.1"
  namespace        = var.ingress_namespace
  create_namespace = true
  depends_on       = [linode_lke_cluster.main]
}

# cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.12.0"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [kubernetes_namespace.cert_manager]
}

# Docker Registry
resource "helm_release" "docker_registry" {
  name       = "docker-registry"
  repository = "https://helm.twun.io"
  chart      = "docker-registry"
  version    = "2.2.2"

  values = [
    yamlencode({
      ingress = {
        enabled = true
        hosts   = [var.registry_domain]
        annotations = {
          "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
          "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
          "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
          "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
        }
        tls = [{
          secretName = "registry-tls"
          hosts      = [var.registry_domain]
        }]
      }

      storage = "s3"

      secrets = {
        htpasswd = htpasswd_password.registry.sha256
        s3 = {
          accessKey = linode_object_storage_key.registry.access_key
          secretKey = linode_object_storage_key.registry.secret_key
        }
      }

      s3 = {
        region         = var.object_storage_cluster_region
        regionEndpoint = "${var.object_storage_cluster_region}-1.linodeobjects.com"
        bucket         = linode_object_storage_bucket.registry.label
        secure         = true
      }
    })
  ]

  depends_on = [
    helm_release.nginx_ingress,
    helm_release.cert_manager,
  ]
}

# htpasswd hash generation
resource "htpasswd_password" "registry" {
  password = random_password.registry_password.result
  salt     = substr(sha256(random_password.registry_password.result), 0, 8)
}
