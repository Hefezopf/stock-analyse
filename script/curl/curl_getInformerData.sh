#!/bin/bash

# Query quotes on daily base from Comdirect Informer
# Call: . curl_getInformerData.sh SYMBOLS
# Example: . script/curl/curl_getInformerData.sh '*BEI IBM TUI1'
#
# Reihenfolge neue Werte aufnehmen:
# ---------------------------------
# . analyse.sh 'BEI' 2 9 25 cc
# edit ticker_name_id.txt
# . script/curl/curl_getInformerData.sh 'BEI'
# mc 'BEI'
# add BEI to config stock_symbols.txt

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

export DATA_INFORMER_DIR="data" # where to write informer intermediate files; For migration (curl_getInformerData.sh)

# Parameter
symbolsParam=$1

if { [ -z "$symbolsParam" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Example: . curl_getInformerData.sh '*BEI IBM TUI1'"
  exit 1
fi

mkdir -p "$TEMP_DIR/config"
cp "$TICKER_NAME_ID_FILE" "$TEMP_DIR/config"

countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam"
mkdir -p "$DATA_INFORMER_DIR"
yesterday=$(date --date="-1 day" +"%Y-%m-%d") # Daten immer nach Mitternacht holen! -1 Tag
errorSymbols=""
echo "---------------"
START_TIME_MEASUREMENT=$(date +%s);

for symbol in $symbolsParam
do
    if [ "${symbol::1}" = '*' ]; then  
        symbol="${symbol:1:7}"
    fi
    symbol="${symbol^^}" # all uppercase

    informerDataFile="$DATA_INFORMER_DIR/$symbol.txt"
    touch "$informerDataFile"
    fileSize=$(stat -c %s "$informerDataFile")
    if [ "$fileSize" -eq "0" ]; then
        echo "$symbol: Create new file" | tee -a "$informerDataFile"
    fi
  
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE_MEM")
    ID_NOTATION=$(echo "$lineFromTickerFile" | awk 'BEGIN{FS="\t"} {print $3}')
    dataAlreadyThere=$(grep -m1 -P "^$yesterday\t" "$informerDataFile")
    if { [ -z "$dataAlreadyThere" ]; } then
        asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
        if [ "$asset_type" = 'INDEX' ]; then
            curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        fi
        if [ "$asset_type" = 'STOCK' ]; then
            curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        fi
        if [ "$asset_type" = 'COIN' ]; then
            curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/zertifikate/detail/uebersicht/indexzertifikat.html?ID_NOTATION=$ID_NOTATION")
        fi
        
        value=$(echo "$curlResponse" 2>/dev/null | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*')
        if [ "${value:28:2}" = '--' ]; then
            echo "Warning: '$symbol' value NOT a integer number! Trying with next exchange..."
            value=$(echo "$curlResponse" 2>/dev/null | grep -m3 "</span></div></span>" | sort -r | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*')              
        fi
        value=${value%*"<"*}
        value=${value%*"<"*}
        value=${value%*"<"*}
        value="${value:28}"
        if [ "$value" ]; then
            value="${value//\./}"
            value="${value//,/.}"
            valueTest="${value//\./}"
            if [ "${valueTest::1}" = '-' ]; then
                echo "Warning: '$symbol' value NOT a integer number! Taking value from yesterday."
                value=$(head -1 "$informerDataFile" | cut -f 2)
            fi
            echo "$symbol: $ID_NOTATION;$yesterday;$value€"
            numOfLines=$(awk 'END { print NR }' "$informerDataFile")
            numOfLinesToFill=$((101 - numOfLines))
            while [ "$numOfLinesToFill" -gt 0 ]; do
                dayBefore=$(date --date="-$numOfLinesToFill day" +"%Y-%m-%d")
                sed -i "1s/^/$dayBefore	$value\n/" "$informerDataFile"
                numOfLinesToFill=$((numOfLinesToFill - 1))
            done
            sed -i "1,100!d" "$informerDataFile" # Alles was länger als 100 Zeilen ist löschen
        else
            echo "Error: '$symbol' retrieving value for Symbol (Wrong Type? INDEX or COIN?)."
            errorSymbols="$errorSymbols $symbol"
        fi
    else
        echo "Info: '$symbol' actual data for symbol already there. NO CURL query needed."
    fi
done
echo "---------------"
if { [ "$errorSymbols" ]; } then
    echo "Summary Errors for:$errorSymbols"
    errorLength="${#errorSymbols}"
    if [ "$errorLength" -gt 200 ]; then
        echo "Error: Generell CURL data retrieving problems! Rerun again later?"
        exit 2
    fi
fi

rm -rf "$TEMP_DIR"/config

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
