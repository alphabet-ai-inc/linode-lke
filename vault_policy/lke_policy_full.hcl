# Read/write all secrets in secret/data/lke/*
path "secret/data/lke/*" {
  capabilities = ["read", "list", "create", "update", "delete"]
}

# Read/list metadata for secrets in secret/metadata/lke/*
path "secret/metadata/lke/*" {
  capabilities = ["read", "list"]
}

path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}