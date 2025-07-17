cluster_name = "lke-cluster"
region       = "us-ord"
k8s_version  = "1.33"
pools = [
  {
    type  = "g6-standard-2"
    count = 2
  }
]
object_storage_cluster_region = "us-ord"
tags                          = ["terraform", "lke", "docker-registry"]
