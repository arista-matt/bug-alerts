#!/usr/bin/env bash

: "${BUG_ALERT_TOKEN:?Set BUG_ALERT_TOKEN to your Arista bug alert API token}"
encoded_token=$(echo -n "$BUG_ALERT_TOKEN" | base64)
url='https://www.arista.com/custom_data/bug-alert/alertBaseDownloadApi.php'
curl -sf \
  -H "Content-Type: application/json" \
  -d "{\"token_auth\":\"$encoded_token\",\"file_version\":\"2\"}" \
  "${url}" > bug-alerts.json
