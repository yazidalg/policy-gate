#!/bin/bash

set -euo pipefail

input_file="${1:-}"

if [[ -z "$input_file" ]]; then
  echo "Usage: $0 <input-json>"
  exit 1
fi

echo "Running OPA Rego policies"

opa eval -i "$input_file" -d policies/normalized-trivy.rego "data.trivy.normalized.output" \
  | jq -c '.result[0].expressions[0].value[][]' >> result-normalized.ndjson

sleep 4

# BSD sed (macOS) requires an explicit, even if empty, backup suffix when using -i
sed -i '' 's/\\n//g' result-normalized.ndjson
