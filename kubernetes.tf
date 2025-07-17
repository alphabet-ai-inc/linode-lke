
resource "local_file" "kubeconfig" {
  content    = base64decode(data.linode_lke_cluster.main.kubeconfig)
  filename   = "${path.module}/kubeconfig.yaml"
  depends_on = [linode_lke_cluster.main]
}
