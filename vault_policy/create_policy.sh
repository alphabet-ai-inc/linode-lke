#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

TMP_DIR="${SCRIPT_DIR}/../tmp"
VAULT_ADDR_FILE="${TMP_DIR}/.vault_addr"
VAULT_TOKEN_FILE="${TMP_DIR}/.vault_token"
POLICY_FILE="${SCRIPT_DIR}/lke_policy_full.hcl"
TOKEN_FILE="${TMP_DIR}/vault_token_with_policy.txt"
POLICY_NAME="lke-full-policy"

if [ ! -f "${VAULT_ADDR_FILE}" ]; then
  echo "Error: Vault address file not found at ${VAULT_ADDR_FILE}"
  exit 1
fi

if [ ! -f "${VAULT_TOKEN_FILE}" ]; then
  echo "Error: Vault token file not found at ${VAULT_TOKEN_FILE}"
  exit 1
fi

VAULT_ADDR=$(cat "${VAULT_ADDR_FILE}" | tr -d '[:space:]')
export VAULT_ADDR
VAULT_TOKEN=$(cat "${VAULT_TOKEN_FILE}" | tr -d '[:space:]')
export VAULT_TOKEN

# check Vault access
if ! vault status > /dev/null; then
  echo "Error: Cannot connect to Vault at ${VAULT_ADDR}"
  exit 1
fi


# Check if file exists
if [ ! -f "$POLICY_FILE" ]; then
  echo "Error: Policy file $POLICY_FILE not found"
  exit 1
fi

# If policy exists - skip creation
if vault policy read "$POLICY_NAME" > /dev/null 2>&1; then
  echo "Policy $POLICY_NAME already exists, skipping creation"
else
  echo "Creating new policy $POLICY_NAME"
  vault policy write "$POLICY_NAME" "$POLICY_FILE"
fi

# Create token
echo "Creating new token with policy $POLICY_NAME"
NEW_TOKEN=$(vault token create \
  -policy="$POLICY_NAME" \
  -ttl=768h \
  -renewable=true \
  -format=json | jq -r '.auth.client_token')

# Save token
echo "$NEW_TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"
echo "Token successfully saved to $TOKEN_FILE"

# Check token
echo "Token capabilities for secret/lke:"
vault token capabilities "$NEW_TOKEN" "secret/data/lke/test"