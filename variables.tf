variable "cluster_name" {
  description = "LKE cluster name"
  type        = string
  default     = "lke-docker-registry"
}

variable "region" {
  description = "Region Linode"
  type        = string
  default     = "us-ord"
}

variable "k8s_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.33"
}

variable "pools" {
  description = "The Node Pool specifications for the Kubernetes cluster. (required)"
  type = list(object({
    type  = string
    count = number
  }))
  default = [
    {
      type  = "g6-standard-2"
      count = 2
    }
  ]
}

variable "main_domain" {
  description = "Domain 2 level"
  type        = string
}

variable "registry_domain" {
  description = "Domain for Docker Registry"
  type        = string
}

variable "registry_bucket_name" {
  description = "Bucket name for Docker Registry"
  type        = string
  default     = "alphabet-ai-registry"
}

variable "object_storage_cluster_region" {
  description = "Region for Cluster Object Storage"
  type        = string
  default     = "us-ord"
}

variable "registry_username" {
  description = "User name for Docker Registry"
  type        = string
  default     = "admin"
}

variable "email" {
  description = "Email for Let's Encrypt"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = list(string)
  default     = ["terraform", "lke", "docker-registry"]
}

variable "ingress_namespace" {
  description = "Namespace for NGINX Ingress Controller"
  type        = string
  default     = "ingress-nginx"
}
