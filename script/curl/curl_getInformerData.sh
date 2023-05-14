#!/bin/bash

# Query quotes on daily base
# Call: . curl_getInformerData.sh SYMBOLS
# Example: . script/curl/curl_getInformerData.sh 'IBM TUI1'

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh
#export DATA_DIR="data"
#export DATA_DIR="data/informer" # Where to read the data; Run migration first! (curl_getInformerData.sh)
export DATA_INFORMER_DIR="data/informer" # where to write informer intermediate files; For migration (curl_getInformerData.sh)


if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: . curl_getInformerData.sh '*IBM TUI1'"
 # exit 1
fi

mkdir -p "$DATA_INFORMER_DIR"
yesterday=$(date --date="-1 day" +"%Y-%m-%d") # Daten immer nach Mitternacht holen! -1
errorSymbols=""
for symbol in $1
do
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-6)
    fi
    symbol=$(echo "$symbol" | tr '[:lower:]' '[:upper:]')

    informerDataFile="$DATA_INFORMER_DIR/$symbol.txt"
    informerDataReverseFile="$DATA_INFORMER_DIR/$symbol.revers.txt"


    # Migration Start
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


 echo "-1--------------"
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
 echo "-2--------------"
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
    dataAlreadyThere=$(grep -m1 -P "^$yesterday\t" "$informerDataFile")
echo "--3-------------"    
    echo "---------------"
    if { [ -z "$dataAlreadyThere" ]; } then
        asset_type=$(echo "$lineFromTickerFile" | cut -f 10)
        if [ "$asset_type" = 'INDEX' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")  
        else
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
        fi
 echo "-4--------------"        
        value=$(echo "$curlResponse" | grep -m1 "&nbsp;EUR<" | grep -o 'medium.*' | cut -f1 -d"<" | cut -c 9-)
 echo "--5-------------"        
        if [ "$asset_type" = 'COIN' ]; then
            curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/zertifikate/detail/uebersicht/indexzertifikat.html?ID_NOTATION=$ID_NOTATION")
            value=$(echo "$curlResponse" | grep -m1 "</span></div></span>" | grep -o 'realtime-indicator--value .*' | cut -f1 -d"<" | cut -c 29-)
        fi

        if [ "$value" ]; then
            # shellcheck disable=SC2001
            value=$(echo "$value" | sed "s/,/./g") 
            echo "Symbol:$symbol ID_NOTATION:$ID_NOTATION Date:$yesterday Value:$value"     
            cat "$informerDataFile" | tac > "$informerDataReverseFile"
            numOfLines=$(awk 'END { print NR }' "$informerDataReverseFile")
            numOfLinesToFill=$((100 - numOfLines))
            while [ "$numOfLinesToFill" -gt 0 ]; do
                dayBefore=$(date --date="-$numOfLinesToFill day" +"%Y-%m-%d")              
                echo "$dayBefore	$value" >> "$informerDataReverseFile"
                numOfLinesToFill=$((numOfLinesToFill - 1))
            done
            cat "$informerDataReverseFile" | tac > "$informerDataFile"
            head -n100 "$informerDataFile" > "$informerDataReverseFile"
            mv "$informerDataReverseFile" "$informerDataFile"
        else
            echo "Error retrieving Value for Symbol:$symbol"
            errorSymbols="$errorSymbols $symbol"
        fi
    else
        echo "Actuall Data for Symbol:$symbol already there. NO CURL!"
    fi  
done

if { [ "$errorSymbols" ]; } then
    echo "Summary Errors for:$errorSymbols"
fi