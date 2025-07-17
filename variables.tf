variable "cluster_name" {
  description = "LKE cluster name"
  type        = string
  default     = "lke-main"
}

variable "region" {
  description = "Region for LKE"
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

variable "tags" {
  description = "Tags for resources"
  type        = list(string)
  default     = ["terraform", "lke"]
}

variable "vault_url" {
  type    = string
  default = "https://vault.sushkovs.ru"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "server_group_name" {
  type    = string
  default = "lke"
}