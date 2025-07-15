cluster_name    = "lke-cluster"
region          = "us-ord"
registry_domain = "registry.aztech-ai.com"
main_domain     = "aztech-ai.com"
email           = "jorgepassano@gmail.com"
k8s_version     = "1.33"
pools = [
  {
    type  = "g6-standard-2"
    count = 2
  }
]
object_storage_cluster_region = "us-ord"
registry_username             = "admin"
tags                          = ["terraform", "lke", "docker-registry"]
