#!/usr/bin/env bash

# Call: sh ./script/marketcap-update.sh SYMBOLS
# Example: sh ./script/marketcap-update.sh 'BEI VH2' 
# alias ???='/d/code/stock-analyse/script/marketcap-update.sh $1'

#set -x

TICKER_NAME_ID_FILE=config/ticker_name_id.txt
symbolsParam=$1

if  [ -z "$symbolsParam" ]; then
  echo "Not all parameters specified!"
  echo "Call: sh ./script/marketcap-update.sh SYMBOLS"
  echo "Example: sh ./script/marketcap-update.sh 'BEI VH2'"
  exit 1
fi

for symbol in $symbolsParam
do
  # Remove prefix '*' if persent
  if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
    symbol=$(echo "$symbol" | cut -b 2-6)
  fi
  ID_NOTATION=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 3)
  SYMBOL_NAME=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 2)

  echo $symbol ...

  # Mrd.
  marktkap=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -m 1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
  if [ "$marktkap" ]; then
    echo "$symbol $marktkap Mrd."
  else
    # Bil.
    marktkap=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -m 1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
    if [ "$marktkap" ]; then
        marktkap=$(echo "$marktkap"000"")
        echo "$symbol $marktkap Mrd."
    else
        marktkap="?"
        errorSymbols=$(echo "$symbol $errorSymbols")
        echo "ERROR: $symbol $ID_NOTATION= ETF or market cap too small! $marktkap"
    fi
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap/g" "$TICKER_NAME_ID_FILE"
done

echo ""
echo "Symbols with Error: errorSymbols=$errorSymbols"