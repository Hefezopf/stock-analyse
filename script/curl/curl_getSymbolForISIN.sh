#!/bin/bash

# Get Symbol base from Comdirect Informer and check for prefix like 'GB' or 'JP'
# Call: . curl_getSymbolForISIN.sh ISINS
# Example: . script/curl/curl_getSymbolForISIN.sh 'DE0007164600 IE00A10RZP78 NL0010273215 GB00B10RZP78'
#
# Reihenfolge neue Werte aufnehmen:
# ---------------------------------
# . analyse.sh 'BEI' 2 9 25 cc
# edit ticker_name_id.txt
# . script/curl/curl_getSymbolForISIN.sh 'DE0007164600 IE00A10RZP78 NL0010273215 GB00B10RZP78'
# mc 'BEI'
# add BEI to config stock_symbols.txt

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

# Parameter
ISINS=$1

if { [ -z "$ISINS" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Example: . curl_getSymbolForISIN.sh 'DE0007164600 NL0010273215'"
  exit 1
fi

countSymbols=$(echo "$ISINS" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "ISINS($countSymbols):$ISINS"
allSymbols=""
echo "---------------"
START_TIME_MEASUREMENT=$(date +%s);

for ISIN in $ISINS
do
    ISIN="${ISIN^^}" # all uppercase

    preFix="${ISIN:0:2}"
    if { [ "$preFix" = 'GB' ] || [ "$preFix" = 'IE' ] || [ "$preFix" = 'JP' ] ; } then 
        echo "ISIN: $ISIN is a kind GB (Great Britain) or IE (Irland) or JP (Japan) ISIN, skipping because spread too high..."
        continue
    fi
    if { [ "$ISIN" = 'DE0005439004' ] ; } then # DE0005439004=CON
        echo "ISIN: $ISIN is excluded!"
        continue
    fi    

    curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/search/all.html?SEARCH_VALUE=$ISIN")  
    symbol=$(echo "$curlResponse" 2>/dev/null | grep -m1 -A1 "Symbol" | grep td)
    symbol=${symbol%*"<"*}
    symbol="${symbol:47}" # cut off the first 47 characters

    found=$(grep -n "$symbol" "$STOCK_SYMBOLS_FILE")
    if { [ "$found" ]; } then
        echo "Symbol: $ISIN=$symbol already in SA!"
    else
        echo "$ISIN=$symbol"
        allSymbols="$allSymbols $symbol"    
    fi
done
echo "---------------"
echo "Summary allSymbols:$allSymbols"

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
