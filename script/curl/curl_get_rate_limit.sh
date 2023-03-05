#!/bin/bash

# Query rate limit
# Call: . curl_get_rate_limit.sh
# Example: . script/curl/curl_get_rate_limit.sh

# Debug mode
#set -x

curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' -I "https://api.github.com/users/octocat"
