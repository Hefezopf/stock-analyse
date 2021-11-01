#!/bin/bash

# Query quotes on daily base
# Call: sh ./curl_marketstack.sh SYMBOL
# Example: sh ./script/curl/curl_marketstack.sh IBM

# Debug mode
#set -x

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_marketstack.sh IBM"
  exit 1
fi

#export MARKET_STACK_ACCESS_KEY=$MARKET_STACK_ACCESS_KEY
curl -s --location --request GET "https://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${1}.XETRA" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}'
