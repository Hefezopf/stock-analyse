#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: . curl_github_dispatch_sell.sh SYMBOL SELL_PIECES SELL_PRICE
# Example: . script/curl/curl_github_dispatch_sell.sh "BEI 100 9.99"
# !!Only ONE symbol can be passed as parameter!! For example: This list is NOT possible: "BEI BMW"

# Debug mode
#set -x

if { [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Example: . curl_github_dispatch_sell.sh BEI 100 9.99"
  exit 1
fi

curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "sell", "client_payload": {"symbol": "'$1'", "sellPieces": "'$2'", "sellPrice": "'$3'"}}'
