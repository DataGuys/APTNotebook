#!/usr/bin/env bash
# enable_ml_features.sh
# Enables Sentinel UEBA + ML Behavior Analytics analytic rule for a workspace
set -euo pipefail

usage() { echo "Usage: $0 -w <workspace-name> -g <resource-group> -s <subscription-id>"; exit 1; }
while getopts ":w:g:s:h" opt; do
  case $opt in
    w) WORKSPACE="$OPTARG" ;;
    g) RG="$OPTARG" ;;
    s) SUB="$OPTARG" ;;
    h|*) usage ;;
  esac
done
[[ -z "${WORKSPACE:-}" || -z "${RG:-}" || -z "${SUB:-}" ]] && usage

az account set --subscription "$SUB"

WS_ID="/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE"

echo "[+] Enabling UEBA..."
az rest --method PUT --url "$WS_ID/features/UserEntityBehaviorAnalytics?api-version=2021-12-01-preview"   --body '{"properties":{"enabled":true}}'

echo "[+] Enabling ML Behavior Analytics analytic rule..."
RULE_ID="MLBehaviorAnalytics"
az sentinel alert-rule create --workspace-name "$WORKSPACE" -g "$RG" --rule-id "$RULE_ID"   --kind MLBehaviorAnalytics --alert-rule-template-name "c185889c-8e43-4ad7-b54f-14045d5af8dd"   --display-name "ML Behavior Analytics" --severity Medium --enabled true

echo "[+] Sentinel ML features enabled."
