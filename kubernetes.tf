
resource "local_file" "kubeconfig" {
  content    = base64decode(linode_lke_cluster.main.kubeconfig)
  filename   = "${path.module}/kubeconfig.yaml"
  depends_on = [linode_lke_cluster.main]
}

resource "vault_kv_secret_v2" "kubeconfig" {
  mount = "secret"
  name  = "${var.cluster_name}/kubeconfig"
  data_json = jsonencode({
    kubeconfig = base64decode(linode_lke_cluster.main.kubeconfig)
  })
  depends_on = [linode_lke_cluster.main]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [linode_lke_cluster.main]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.12.0"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  timeout    = 300
  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]
  depends_on = [kubernetes_namespace.cert_manager]
}
