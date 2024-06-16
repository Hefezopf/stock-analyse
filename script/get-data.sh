#!/bin/bash

# This script retrieves data from marketstack.
# Call: . get-data.sh SYMBOLS
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# Call example: . get-data.sh 'BEI DAI'
# Precondition:
# Set MARKET_STACK_ACCESS_KEY as ENV Variable (Online)

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

export MARKET_STACK_ACCESS_KEY

# Parameter
symbolsParam=$1

# Prepare
#TEMP_DIR=/tmp
TEMP_DIR=/dev/shm/
rm -rf $TEMP_DIR/tmp.*
mkdir -p temp
TICKER_NAME_ID_FILE=config/ticker_name_id.txt

# Check for multiple identical symbols in cmd. Do not ignore '*'' 
if echo "$symbolsParam" | tr -d '*' | tr '[:lower:]' '[:upper:]' | tr " " "\n" | sort | uniq -c | grep -v '^ *1 '; then
    echo "WARNING: Multiple symbols in parameter list!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

# Analyse stock data for each symbol
for symbol in $symbolsParam
do
    symbolExists=$(grep -n "$symbol" config/stock_symbols.txt)
    if [ "$symbolExists" ]; then
        echo ""
        echo Skip, because "$symbol" exists!
    else
        # Get stock data
        echo ""
        echo "# Get $symbol"
        DATA_FILE="$(mktemp -p $TEMP_DIR)"
        #DATA_DATE_FILE="data/$symbol.txt"
        DATA_DATE_FILE="$DATA_DIR/$symbol.txt"

        DATA_DATE_FILE_TEMP="$(mktemp -p $TEMP_DIR)"
        # https://marketstack.com/documentation
        #exchange="XFRA" # Frankfurt
        exchange="XETRA"
        curl -s --location --request GET "https://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=${exchange}&symbols=${symbol}.${exchange}&limit=100" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}' > "$DATA_DATE_FILE"
        # With volume
        # curl -s --location --request GET "https://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=${exchange}&symbols=${symbol}.${exchange}&limit=100" | jq -jr '.data[]|.date, "T", .close, "T", .volume, "\n"' | awk -F'T' '{print $1 "\t" $3 "\t" $4}' > "$DATA_DATE_FILE"
        fileSize=$(stat -c %s "$DATA_DATE_FILE")
        if [ "$fileSize" -eq "0" ]; then
            echo "<br>" >> $OUT_RESULT_FILE
            echo "!!! $symbol NO data retrieved online; Maybe CURL is blocked?" | tee -a $OUT_RESULT_FILE
            echo "<br>" >> $OUT_RESULT_FILE
        fi

        yesterday=$(date --date="-1 day" +"%Y-%m-%d")
        quoteDate=$(head -n1 "$DATA_DATE_FILE" | awk '{print $1}')
        if [ "$quoteDate" = "$yesterday" ]; then # OK, quote from last trading day
            #echo "OK, quote from last trading day"
            symbolsWithData=$(echo "$symbol $symbolsWithData")
            CurlSymbolName "$symbol" $TICKER_NAME_ID_FILE 14
        else # NOK!
            echo "remove $symbol" 
            rm -rf "$DATA_DATE_FILE"
        fi
    fi
done

echo ""
echo "symbolsWithData="$symbolsWithData""
