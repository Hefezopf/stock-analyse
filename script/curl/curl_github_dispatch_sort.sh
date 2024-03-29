#!/bin/bash

# POST Request to run action in GitHub and trigger workflow
# Call: . curl_github_dispatch_sort.sh
# Example: . script/curl/curl_github_dispatch_sort.sh

# Debug mode
#set -x

curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "sort"}'
