output "kubeconfig_raw" {
  description = "Raw kubeconfig for the LKE cluster"
  value       = base64decode(linode_lke_cluster.main.kubeconfig)
  sensitive   = true
}

output "docker_registry_bucket" {
  description = "Name of the object storage bucket for Docker Registry"
  value       = linode_object_storage_bucket.docker-registry.label
}

output "docker_registry_object_storage_key" {
  description = "Access key for docker registry object storage"
  value       = linode_object_storage_key.docker-registry.access_key
  sensitive   = true
}

output "docker_registry_object_storage_secret_key" {
  description = "Secret key for docker registry object storage"
  value       = linode_object_storage_key.docker-registry.secret_key
  sensitive   = true
}