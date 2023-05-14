#!/bin/bash

# Query quotes on daily base
# Call: . curl_getInformerData.sh SYMBOLS
# Example: . script/curl/curl_getInformerData.sh 'IBM TUI1'

# Debug mode
#set -x

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: . curl_getInformerData.sh 'IBM TUI1'"
 # exit 1
fi

export TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
mkdir -p data/informer
today=$(date --date="-0 day" +"%Y-%m-%d")
for symbol in $1
do
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
    curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
    value=$(echo "$curlResponse" | grep -m1 "&nbsp;EUR<" | grep -o 'medium.*' | cut -f1 -d"<" | cut -c 9-)
    echo "---------------"
    if [ "$value" ]; then
        echo "Symbol:$symbol ID_NOTATION:$ID_NOTATION Date:$today	Value:$value"
        echo "$today	$value" > "./data/informer/$symbol.txt"

    else
        echo "Error retrieving Value"
    fi
done  
