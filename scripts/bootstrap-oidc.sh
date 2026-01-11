#!/usr/bin/env bash
set -euo pipefail

# Requiere: az login ya hecho y permisos para crear apps/roles
GITHUB_OWNER="${GITHUB_OWNER:-hsniama}"
GITHUB_REPO="${GITHUB_REPO:-infra-devops}"
APP_NAME="${APP_NAME:-gh-oidc-infra-devops}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv)}"
TENANT_ID="${TENANT_ID:-$(az account show --query tenantId -o tsv)}"

STATE_RG="${STATE_RG:-rg-tfstate-devops}"
STATE_SA="${STATE_SA:-sttfstate2e9f0a4f}"

echo "==> Creating app registration: $APP_NAME"
APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
az ad sp create --id "$APP_ID" 1>/dev/null

echo "APP_ID=$APP_ID"
echo "TENANT_ID=$TENANT_ID"
echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

echo "==> Assigning Owner at subscription scope (assessment-friendly)"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Owner" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" 1>/dev/null

echo "==> Assigning Storage Blob Data Contributor for tfstate storage"
STATE_SA_ID="$(az storage account show -g "$STATE_RG" -n "$STATE_SA" --query id -o tsv)"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "$STATE_SA_ID" 1>/dev/null

echo "==> Creating federated credentials for GitHub Environments dev/prod"
az ad app federated-credential create --id "$APP_ID" --parameters "{
  \"name\": \"gh-env-dev\",
  \"issuer\": \"https://token.actions.githubusercontent.com\",
  \"subject\": \"repo:${GITHUB_OWNER}/${GITHUB_REPO}:environment:dev\",
  \"audiences\": [\"api://AzureADTokenExchange\"]
}" 1>/dev/null

az ad app federated-credential create --id "$APP_ID" --parameters "{
  \"name\": \"gh-env-prod\",
  \"issuer\": \"https://token.actions.githubusercontent.com\",
  \"subject\": \"repo:${GITHUB_OWNER}/${GITHUB_REPO}:environment:prod\",
  \"audiences\": [\"api://AzureADTokenExchange\"]
}" 1>/dev/null

echo
echo "Done."
echo "Poner esto en GitHub Secrets:"
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
