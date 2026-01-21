#!/usr/bin/env bash
set -euo pipefail

# =========================
# Backend Bootstrap Script
# Crea: RG + Storage Account + Container + Versioning
# =========================

# ---- Config (puedes exportarlas antes o editarlas aquí) ----
LOCATION="${LOCATION:-eastus}"
STATE_RG="${STATE_RG:-rg-tfstate-devops}"
STATE_CONTAINER="${STATE_CONTAINER:-tfstate}"

# Nombre único global (solo minúsculas y números, 3-24 chars)
# Puedes forzarlo exportando STATE_SA antes de correr el script
if [[ -z "${STATE_SA:-}" ]]; then
  RAND="$(openssl rand -hex 4)"
  STATE_SA="sttfstate${RAND}"
fi

echo "==> Using:"
echo "    LOCATION:       $LOCATION"
echo "    STATE_RG:       $STATE_RG"
echo "    STATE_SA:       $STATE_SA"
echo "    STATE_CONTAINER:$STATE_CONTAINER"
echo

# Verifica login
az account show >/dev/null

echo "==> Creating resource group..."
az group create -n "$STATE_RG" -l "$LOCATION" 1>/dev/null

echo "==> Creating storage account..."
az storage account create \
  -g "$STATE_RG" -n "$STATE_SA" -l "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 1>/dev/null

echo "==> Enabling blob versioning..."
az storage account blob-service-properties update \
  --account-name "$STATE_SA" --enable-versioning true 1>/dev/null

echo "==> Creating container..."
az storage container create \
  --name "$STATE_CONTAINER" \
  --account-name "$STATE_SA" \
  --auth-mode login 1>/dev/null

echo
echo "Backend created successfully."
echo "Estas variables se deben setear en el backend HCL y en GitHub  Variables de repositorio:"
echo "STATE_RG=$STATE_RG"
echo "STATE_SA=$STATE_SA"
echo "STATE_CONTAINER=$STATE_CONTAINER"
