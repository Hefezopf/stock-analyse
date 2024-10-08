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
  echo "Not all parameters specified!"
  echo "Example: . curl_getInformerData.sh '*BEI IBM TUI1'"
  exit 1
fi

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
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-7)
    fi
    symbol="${symbol^^}" # all uppercase

    informerDataFile="$DATA_INFORMER_DIR/$symbol.txt"
    touch "$informerDataFile"
    fileSize=$(stat -c %s "$informerDataFile")
    if [ "$fileSize" -eq "0" ]; then
        echo "$symbol: Create new file" | tee -a "$informerDataFile"
    fi
  
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
    dataAlreadyThere=$(grep -m1 -P "^$yesterday\t" "$informerDataFile")
    if { [ -z "$dataAlreadyThere" ]; } then
        asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
        if [ "$asset_type" = 'INDEX' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        else
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        fi
       # value=$(echo "$curlResponse" | grep -m1 "&nbsp;EUR<" | grep -o 'medium.*' | cut -f1 -d"<" | cut -c 9-)
        
        if [ "$asset_type" = 'COIN' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/zertifikate/detail/uebersicht/indexzertifikat.html?ID_NOTATION=$ID_NOTATION")
          # value=$(echo "$curlResponse" | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*' | cut -f1 -d"<" | cut -c 29-)
        fi
        value=$(echo "$curlResponse" | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*' | cut -f1 -d"<" | cut -c 29-)

        if [ "$value" ]; then
            # shellcheck disable=SC2001
            value=$(echo "$value" | sed "s/\.//") # Wenn Punkt dann löschen 1.000,00 -> 1000,00
            # shellcheck disable=SC2001
            value=$(echo "$value" | sed "s/,/./g") # Replace , -> . 1000,00 -> 1000.00

            # shellcheck disable=SC2001
            valueTest=$(echo "$value" | sed "s/\.//g") # Replace , -> . 1000.00 -> 100000
            case "$valueTest" in
                ''|*[!0-9]*) echo "Error: PIECES Not a integer number!" >&2; exit 3 ;;
            esac

            echo "$symbol: $ID_NOTATION;$yesterday;$value€"
            numOfLines=$(awk 'END { print NR }' "$informerDataFile")
            numOfLinesToFill=$((101 - numOfLines))

            # oldtext='2024-09-08	uter-spacing--small-top">nbsp;EUR'
            # newtext="2024-09-08	$value"
            # sed -i "s/$oldtext/$newtext/g" "$informerDataFile"

            while [ "$numOfLinesToFill" -gt 0 ]; do
                dayBefore=$(date --date="-$numOfLinesToFill day" +"%Y-%m-%d")
                sed -i "1s/^/$dayBefore	$value\n/" "$informerDataFile"
                numOfLinesToFill=$((numOfLinesToFill - 1))
            done
            sed -i "1,100!d" "$informerDataFile" # Alles was länger als 100 Zeilen ist löschen
        else
            echo "Error retrieving Value for Symbol (Wrong Type? INDEX or COIN?):$symbol"
            errorSymbols="$errorSymbols $symbol"
        fi
    else
        echo "$symbol:	Actual data already there. NO CURL query needed!"
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

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
