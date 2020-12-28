#!/bin/bash

# Call: ./curl_github_dispatch.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC RSI
# Call example: ./script/curl_github_dispatch.sh "CEC" 1 offline underrated 9 88
# !! Only one symbol can be passed as parameter!! This is not possible: "INL BMW" 
set -x
curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "'$1'", "percentage": "'$2'", "query": "'$3'", "rated": "'$4'", "stochastic": "'$5'", "RSI": "'$6'"}'
