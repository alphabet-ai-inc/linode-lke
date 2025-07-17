
resource "local_file" "kubeconfig" {
  content    = base64decode(data.linode_lke_cluster.main.kubeconfig)
  filename   = "${path.module}/kubeconfig.yaml"
  depends_on = [linode_lke_cluster.main]
}

resource "vault_kv_secret_v2" "kubeconfig" {
  mount = "secret"
  name  = "${var.server_group_name}/kubeconfig"
  data_json = jsonencode({
    kubeconfig = base64decode(data.linode_lke_cluster.main.kubeconfig)
  })
  depends_on = [linode_lke_cluster.main]
}