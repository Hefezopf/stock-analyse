#!/bin/bash

# Query quotes on daily base
# Call: sh ./curl_marketstack.sh SYMBOL
# Call example: sh ./script/curl/curl_marketstack.sh IBM
set -x
export MARKET_STACK_ACCESS_KEY=$MARKET_STACK_ACCESS_KEY1
curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XNAS&symbols=${1}" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}'
