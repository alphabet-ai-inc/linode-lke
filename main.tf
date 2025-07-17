# LKE cluster
resource "linode_lke_cluster" "main" {
  label       = var.cluster_name
  k8s_version = var.k8s_version
  region      = var.region
  tags        = var.tags
  apl_enabled = false
  dynamic "pool" {
    for_each = var.pools
    content {
      type  = pool.value["type"]
      count = pool.value["count"]
    }
  }

}

# Object Storage bucket for Docker Registry
resource "linode_object_storage_bucket" "docker-registry" {
  region = var.object_storage_cluster_region
  label  = var.registry_bucket_name
}

# Object Storage keys
resource "linode_object_storage_key" "docker-registry" {
  label = "docker-registry-key"

  bucket_access {
    bucket_name = linode_object_storage_bucket.docker-registry.label
    region      = var.object_storage_cluster_region
    permissions = "read_write"
  }
}