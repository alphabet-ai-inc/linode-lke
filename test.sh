#!/bin/bash
set -e

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed. Aborting."; exit 1; }
command -v nslookup >/dev/null 2>&1 || { echo "nslookup is required but not installed. Aborting."; exit 1; }

# Read main.auto.tfvars
TFVARS_FILE="main.auto.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
  echo "Error: $TFVARS_FILE not found"
  exit 1
fi

REGISTRY_DOMAIN=$(grep 'registry_domain' $TFVARS_FILE | awk -F '"' '{print $2}')
REGISTRY_USERNAME=$(grep 'registry_username' $TFVARS_FILE | awk -F '"' '{print $2}')
if [ -z "$REGISTRY_DOMAIN" ] || [ -z "$REGISTRY_USERNAME" ]; then
  echo "Error: Could not parse registry_domain or registry_username from $TFVARS_FILE"
  exit 1
fi

# Read outputs.json
OUTPUTS_FILE="outputs.json"
if [ ! -f "$OUTPUTS_FILE" ]; then
  echo "Error: $OUTPUTS_FILE not found. Run 'terraform output -json > outputs.json' first."
  exit 1
fi

REGISTRY_PASSWORD=$(jq -r '.docker_registry_password.value' $OUTPUTS_FILE)
INGRESS_IP=$(jq -r '.ingress_ip.value' $OUTPUTS_FILE)
if [ -z "$REGISTRY_PASSWORD" ] || [ -z "$INGRESS_IP" ]; then
  echo "Error: Could not parse docker_registry_password or ingress_ip from $OUTPUTS_FILE"
  exit 1
fi

# Check DNS with retries
MAX_DNS_ATTEMPTS=1
DNS_ATTEMPT=1
until nslookup $REGISTRY_DOMAIN; do
  echo "Waiting for DNS to propagate (attempt $DNS_ATTEMPT/$MAX_DNS_ATTEMPTS)..."
  sleep 10
  ((DNS_ATTEMPT++))
  if [ $DNS_ATTEMPT -gt $MAX_DNS_ATTEMPTS ]; then
    echo "DNS propagation failed after $MAX_DNS_ATTEMPTS attempts. Using Ingress IP: $INGRESS_IP"
    REGISTRY_DOMAIN=$INGRESS_IP
    break
  fi
done

# Use https for fomain, if not use IP
if [[ ! $REGISTRY_DOMAIN =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  REGISTRY_DOMAIN="https://$REGISTRY_DOMAIN"
fi

# Check login with retries
MAX_LOGIN_ATTEMPTS=1
LOGIN_ATTEMPT=1
until docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $REGISTRY_DOMAIN || [ $LOGIN_ATTEMPT -gt $MAX_LOGIN_ATTEMPTS ]; do
  echo "Login attempt $LOGIN_ATTEMPT failed, retrying in 10 seconds..."
  sleep 10
  ((LOGIN_ATTEMPT++))
done
if [ $LOGIN_ATTEMPT -gt $MAX_LOGIN_ATTEMPTS ]; then
  echo "Failed to login to registry after $MAX_LOGIN_ATTEMPTS attempts"
  exit 1
fi

# Test push/pull
docker pull alpine:latest
docker tag alpine:latest $REGISTRY_DOMAIN/test-image:latest
docker push $REGISTRY_DOMAIN/test-image:latest
docker pull $REGISTRY_DOMAIN/test-image:latest
docker rmi $REGISTRY_DOMAIN/test-image:latest

echo "Registry test passed!"
