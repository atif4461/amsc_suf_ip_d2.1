#!/usr/bin/env bash
set -euo pipefail

TOKEN="$(python get_sf_token.py)"

#SUBMIT_RESP="$(curl -X GET "https://api.iri.nersc.gov/api/v1/filesystem/download/e525a224-61c1-419f-9642-91168c792e39?path=%2Fglobal%2Fshomes%2Fa%2Fatif%2Ffm4npp%2Famsc-d2%2Fdistribution_tracks.png" \
#  -H "accept: application/json" \
#  -H "Authorization: Bearer $TOKEN" \
#  -H "Content-Type: application/json" \
#  )"

SUBMIT_RESP="$(curl -X POST \
  "https://api.iri.nersc.gov/api/v1/filesystem/download/e525a224-61c1-419f-9642-91168c792e39?path=%2Fglobal%2Fhomes%2Fa%2Fatif%2Fdistribution_tracks.png" \
  -H "Authorization: Bearer $TOKEN" \
  )"

TASK_URI="$(echo "$SUBMIT_RESP" | jq -r '.task_uri')"

while true; do
  TOKEN="$(python get_sf_token.py)"
  RESP="$(curl -sS -H "Authorization: Bearer $TOKEN" "$TASK_URI")"
  STATUS="$(echo "$RESP" | jq -r '.status')"

  echo "status=$STATUS"

  case "$STATUS" in
    completed|failed)
      echo "$RESP" | jq
      break
      ;;
    *)
      sleep 5
      ;;
  esac
done
