#!/bin/bash

# Query quotes on daily base from Comdirect Informer
# Call: . curl_getInformerData.sh SYMBOLS
# Example: . script/curl/curl_getInformerData.sh '*BEI IBM TUI1'

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

export DATA_INFORMER_DIR="data/informer" # where to write informer intermediate files; For migration (curl_getInformerData.sh)

# Parameter
symbolsParam=$1

if { [ -z "$symbolsParam" ]; } then
  echo "Not all parameters specified!"
  echo "Example: . curl_getInformerData.sh '*BEI IBM TUI1'"
 # exit 1
fi

echo "!!DATA_INFORMER_DIR $DATA_INFORMER_DIR "

countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam"
mkdir -p "$DATA_INFORMER_DIR"
yesterday=$(date --date="-1 day" +"%Y-%m-%d") # Daten immer nach Mitternacht holen! -1
errorSymbols=""
echo "---------------"
START_TIME_MEASUREMENT=$(date +%s);
for symbol in $symbolsParam
do
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-6)
    fi
    symbol=$(echo "$symbol" | tr '[:lower:]' '[:upper:]')

    informerDataFile="$DATA_INFORMER_DIR/$symbol.txt"

    touch "$informerDataFile"
    fileSize=$(stat -c %s "$informerDataFile")
    if [ "$fileSize" -eq "0" ]; then
        echo "$symbol: Create new file" | tee -a "$informerDataFile"
    fi
  

    # Migration Start
# informerDataReverseFile="$DATA_INFORMER_DIR/$symbol.revers.txt"    
    # dataFile="./data/$symbol.txt"
    # cp "$dataFile" "$DATA_INFORMER_DIR"
    # lastLine=$(head -n1 "$dataFile") 
    # cat "$informerDataFile" | tac > "$informerDataReverseFile"
    # allLines=""
    # i=10
    # while [ "$i" -gt 0 ]; do
    #     allLines=$(echo -e "$allLines\n$lastLine")
    #     i=$((i - 1))
    # done
    # echo "$lastLine" >> "$informerDataReverseFile"
    # cat "$informerDataReverseFile" | tac > "$informerDataFile"
    # rm "$informerDataReverseFile"
    # head -n -10 "$informerDataFile" > tmp.txt && mv tmp.txt "$informerDataFile"
    # Migration Ende


    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
    dataAlreadyThere=$(grep -m1 -P "^$yesterday\t" "$informerDataFile")
    if { [ -z "$dataAlreadyThere" ]; } then
        asset_type=$(echo "$lineFromTickerFile" | cut -f 10)
        if [ "$asset_type" = 'INDEX' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        else
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        fi     
        value=$(echo "$curlResponse" | grep -m1 "&nbsp;EUR<" | grep -o 'medium.*' | cut -f1 -d"<" | cut -c 9-)
        if [ "$asset_type" = 'COIN' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/zertifikate/detail/uebersicht/indexzertifikat.html?ID_NOTATION=$ID_NOTATION")
            value=$(echo "$curlResponse" | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*' | cut -f1 -d"<" | cut -c 29-)
        fi
        if [ "$value" ]; then
            # shellcheck disable=SC2001
            value=$(echo "$value" | sed "s/,/./g")
            echo "$symbol: $ID_NOTATION;$yesterday;$value€"
            
            # cat "$informerDataFile" | tac > "$informerDataReverseFile"
            # numOfLines=$(awk 'END { print NR }' "$informerDataReverseFile")
            # numOfLinesToFill=$((101 - numOfLines))
            # while [ "$numOfLinesToFill" -gt 0 ]; do
            #     dayBefore=$(date --date="-$numOfLinesToFill day" +"%Y-%m-%d")
            #     echo "$dayBefore	$value" >> "$informerDataReverseFile"
            #     numOfLinesToFill=$((numOfLinesToFill - 1))
            # done
            # cat "$informerDataReverseFile" | tac > "$informerDataFile"
            # head -n100 "$informerDataFile" > "$informerDataReverseFile"
            # mv "$informerDataReverseFile" "$informerDataFile"



            numOfLines=$(awk 'END { print NR }' "$informerDataFile")
            numOfLinesToFill=$((101 - numOfLines))
            while [ "$numOfLinesToFill" -gt 0 ]; do
                dayBefore=$(date --date="-$numOfLinesToFill day" +"%Y-%m-%d")
                sed -i "1s/^/$dayBefore	$value\n/" "$informerDataFile"
                numOfLinesToFill=$((numOfLinesToFill - 1))
            done
            sed -i "1,100!d" "$informerDataFile"






        else
            echo "Error retrieving Value for Symbol:$symbol"
            errorSymbols="$errorSymbols $symbol"
        fi
    else
        echo "$symbol:	Actuall Data already there. NO CURL!"
    fi  
done
echo "---------------"
if { [ "$errorSymbols" ]; } then
    echo "Summary Errors for:$errorSymbols"
fi

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
