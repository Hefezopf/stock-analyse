#!/bin/bash

# Mapping from SYMBOL to Stock name
# Call: sh ./curl_figi.sh SYMBOL
# Call example: sh ./script/curl/curl_figi.sh IBM
set -x
curl --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${1}'"}]' | jq '.[0].data[0].name'
