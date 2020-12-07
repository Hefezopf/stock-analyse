#!/bin/bash
# Call: ./curl_figi.sh SYMBOL
# Call example: ./curl_figi.sh IBM
set -x
#curl 'https://api.openfigi.com/v2/mapping' --request POST --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${1}'"}]' | jq '.[0].data[0]'
curl 'https://api.openfigi.com/v2/mapping' --request POST --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${1}'"}]' | jq '.[0].data[0].name'
