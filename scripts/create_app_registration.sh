#!/usr/bin/env bash
# create_app_registration.sh
# Automates Azure AD app registration for Sentinel notebooks

set -euo pipefail

usage() {
  echo "Usage: $0 -w <workspace-name> -g <resource-group> -s <subscription-id>"
  exit 1
}

while getopts ":w:g:s:h" opt; do
  case $opt in
    w) WORKSPACE_NAME="$OPTARG" ;;
    g) RESOURCE_GROUP="$OPTARG" ;;
    s) SUBSCRIPTION_ID="$OPTARG" ;;
    h|*) usage ;;
  esac
done

[[ -z "${WORKSPACE_NAME:-}" || -z "${RESOURCE_GROUP:-}" || -z "${SUBSCRIPTION_ID:-}" ]] && usage

az account set --subscription "$SUBSCRIPTION_ID"

echo "[+] Creating Azure AD app registration..."
APP_ID=$(az ad app create --display-name "SentinelNotebookApp-$(date +%s)" --query appId -o tsv)
SP_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv)

echo "[+] Creating client secret (1‑year)..."
CLIENT_SECRET=$(az ad app credential reset --id "$APP_ID" --append --years 1 --query password -o tsv)

TENANT_ID=$(az account show --query tenantId -o tsv)
WS_ID=$(az monitor log-analytics workspace show --workspace-name "$WORKSPACE_NAME" -g "$RESOURCE_GROUP" --query customerId -o tsv)
WS_SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE_NAME"

echo "[+] Adding API permissions..."
# Microsoft Graph Directory.Read.All + User.Read.All
az ad app permission add --id "$APP_ID" --api 00000003-0000-0000-c000-000000000000   --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Role                      7427ee73-3c47-4940-b94d-5de1468b9e71=Role

# Log Analytics API Data.Read
az ad app permission add --id "$APP_ID" --api 31c0a9e7-8d7d-4d1f-a92d-cde7c675a1ca --api-permissions e8f6e161-84d0-4cd7-9441-2d46ec9ec3d5=Role

echo "[+] Granting admin consent..."
az ad app permission admin-consent --id "$APP_ID"

echo "[+] Assigning RBAC roles..."
az role assignment create --assignee "$SP_ID" --role "Log Analytics Reader" --scope "$WS_SCOPE"
az role assignment create --assignee "$SP_ID" --role "Microsoft Sentinel Reader" --scope "$WS_SCOPE"

cat <<EOF

App Registration complete!
  CLIENT_ID=$APP_ID
  CLIENT_SECRET=$CLIENT_SECRET
  TENANT_ID=$TENANT_ID
  WORKSPACE_ID=$WS_ID

Copy these values into config/msticpyconfig.yaml (or export as env vars) before running the notebook.
EOF
