output "docker_registry_password" {
  description = "Docker registry password"
  value       = random_password.registry_password.result
  sensitive   = true
}

output "registry_url" {
  description = "Docker Registry URL"
  value       = "https://${var.registry_domain}"
}

output "ingress_ip" {
  description = "NGINX Ingress Controller IP"
  value       = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
}

output "registry_username" {
  description = "Docker Registry username"
  value       = var.registry_username
}
