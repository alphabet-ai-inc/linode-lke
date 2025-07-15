# Get existing 2nd level domain
data "linode_domain" "main" {
  domain = var.main_domain
}

# Get existing nginx-ingress
data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.ingress_namespace
  }
  depends_on = [helm_release.nginx_ingress]
}

# DNS-record for registry domain
resource "linode_domain_record" "registry" {
  domain_id   = data.linode_domain.main.id
  name        = "registry"
  record_type = "A"
  target      = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
  ttl_sec     = 300
  depends_on  = [helm_release.nginx_ingress]
}
