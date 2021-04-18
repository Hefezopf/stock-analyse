#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: sh ./curl_github_dispatch_buy.sh SYMBOL AVERAGE
# Example: sh ./script/curl/curl_github_dispatch_buy.sh "BEI" 9.99
# !!Only ONE symbol can be passed as parameter!! For example: This list is NOT possible: "BEI BMW" 9.99

if { [ -z "$1" ] || [ -z "$2" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_buy.sh BEI 9.99"
  exit 1
fi
set -x
curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "buy", "client_payload": {"symbol": "'$1'", "avg": "'$2'"}}'
