#!/bin/bash
#./analyse.sh $1 $2 $3 $4 $5
set -x
curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "MSF.XETRA", "percentage": "1", "query": "online", "rated": "underrated", "stochastic": "40"}'
#curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "MSF.XETRA", "percentage": "1", "query": "online", "rated": "underrated", "stochastic": "40"}'
