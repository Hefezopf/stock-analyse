#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: sh ./curl_github_dispatch_buy.sh SYMBOL PRICE PIECES
# Example: sh ./script/curl/curl_github_dispatch_buy.sh "BEI" 9.99 100
# !!Only ONE symbol can be passed as parameter!! For example: This list is NOT possible: "BEI BMW" 9.99 100

# To uppercase
#symbolParam=${1^^}
symbolParam=$(echo "${1}" | tr '[:lower:]' '[:upper:]')

echo "(re)buy ${symbolParam} ${2} ${3} ..."

if { [ -z "$symbolParam" ] || [ -z "$2" ] || [ -z "$3" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_buy.sh BEI 9.99 100"
  exit 1
fi

set -x
curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "buy", "client_payload": {"symbol": "'$symbolParam'", "price": "'$2'", "pieces": "'$3'"}}'
