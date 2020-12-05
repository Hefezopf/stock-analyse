#!/bin/bash
# Call: ./curl.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC
# Call example: ./curl.sh "INL.XETRA" 1 offline underrated 20
set -x
curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "'$1'", "percentage": "'$2'", "query": "'$3'", "rated": "'$4'", "stochastic": "'$5'"}'
#curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "MSF.XETRA", "percentage": "1", "query": "online", "rated": "underrated", "stochastic": "40"}'
