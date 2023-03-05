#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call:  . curl_github_dispatch_buy.sh SYMBOL PIECES PRICE
# Example: . script/curl/curl_github_dispatch_buy.sh "BEI" 100 9.99 
# !!Only ONE symbol can be passed as parameter!! For example: This list is NOT possible: "BEI BMW" 100 9.99

# Debug mode
#set -x

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "(re)buy $symbolParam $2 $3 ..."

if { [ -z "$symbolParam" ] || [ -z "$2" ] || [ -z "$3" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_buy.sh BEI 100 9.99"
  exit 1
fi

curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "buy", "client_payload": {"symbol": "'$symbolParam'", "pieces": "'$2'", "price": "'$3'"}}'
