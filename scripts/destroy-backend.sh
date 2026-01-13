#!/usr/bin/env bash
set -euo pipefail

# =========================
# Backend Destroy Script
# Borra: RG backend (Storage + container incluidos)
# =========================

STATE_RG="${STATE_RG:-rg-tfstate-devops}"

echo "This will DELETE the resource group: $STATE_RG"
echo "Type DELETE to confirm:"
read -r CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
  echo "Aborted."
  exit 1
fi

az account show >/dev/null

echo "==> Deleting resource group..."
az group delete -n "$STATE_RG" --yes --no-wait

echo "Deletion requested. Azure will remove it asynchronously."
