#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: . curl_github_dispatch_analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI
# Example: . script/curl/curl_github_dispatch_analyse.sh "CEC" 1 offline 9 25
# Example: . script/curl/curl_github_dispatch_analyse.sh "*GIS" 1 online 9 25
# !!Only one symbol can be passed as parameter!! For example: This list is NOT possible: "CEC *GIS" 

# Debug mode
#set -x

if { [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; } then
  echo "Not all parameters specified!"
  echo "Example: . curl_github_dispatch_analyse.sh \"*GIS\" 1 offline 9 25"
  exit 1
fi

curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "analyse", "client_payload": {"symbols": "'$1'", "percentage": "'$2'", "query": "'$3'", "stochastic": "'$4'", "RSI": "'$5'"}}'
