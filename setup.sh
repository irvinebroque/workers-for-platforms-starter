#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

APP_NAME="hello-world"

echo "Installing npm dependencies..."
npm install

if [[ ! -f .env ]]; then
  echo "Error: .env file not found. Create it from .env.example first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

required_vars=(
  "CLOUDFLARE_API_TOKEN"
  "CLOUDFLARE_ACCOUNT_ID"
  "CLOUDFLARE_ZONE_NAME"
  "COMPANY_EMAIL_DOMAIN"
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Error: $var_name is missing or empty in .env" >&2
    exit 1
  fi
done

echo "Initializing Terraform..."
terraform init -input=false >/dev/null

echo "Applying Terraform configuration..."
npm run deploy

echo "Uploading app worker '$APP_NAME' to dispatch namespace 'apps'..."
npm run upload -- "$APP_NAME"

echo
echo "Uploaded app URL: https://${APP_NAME}.apps.${CLOUDFLARE_ZONE_NAME}"
