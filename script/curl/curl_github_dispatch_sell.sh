#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: sh ./curl_github_dispatch_sell.sh SYMBOL
# Example: sh ./script/curl/curl_github_dispatch_sell.sh "CEC"
# !!Only ONE symbol can be passed as parameter!! For example: This list is NOT possible: "CEC BMW" 

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_sell.sh CEC"
  exit 1
fi
set -x
curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "sell", "client_payload": {"symbol": "'$1'"}}'
