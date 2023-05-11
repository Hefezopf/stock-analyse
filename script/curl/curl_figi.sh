#!/bin/bash

# Request a real Stock name for a given SYMBOL name
# Call: . curl_figi.sh SYMBOL
# Example: . script/curl/curl_figi.sh IBM

# Debug mode
#set -x

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: . curl_figi.sh IBM"
  exit 1
fi

curl --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${1}'"}]' | jq '.[0].data[0].name'
