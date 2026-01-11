#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-gh-oidc-infra-devops}"

echo "==> Finding appId for display name: $APP_NAME"
APP_OBJECT_ID="$(az ad app list --display-name "$APP_NAME" --query '[0].id' -o tsv)"

if [[ -z "$APP_OBJECT_ID" ]]; then
  echo "App not found. Nothing to delete."
  exit 0
fi

echo "This will DELETE the App Registration (and its SP + federated creds):"
echo "$APP_NAME ($APP_OBJECT_ID)"
echo "Type DELETE to confirm:"
read -r CONFIRM
if [[ "$CONFIRM" != "DELETE" ]]; then
  echo "Aborted."
  exit 1
fi

az ad app delete --id "$APP_OBJECT_ID"
echo "App deleted."
