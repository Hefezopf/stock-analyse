#!/usr/bin/env bash

# Call: sh ./script/marktkapitalisierung.sh SYMBOLS
# Example: sh ./script/marktkapitalisierung.sh 'BEI VH2' 
# alias ???='/d/code/stock-analyse/script/marktkapitalisierung.sh $1'

TICKER_NAME_ID_FILE=../config/ticker_name_id.txt
symbolsParam=$1

for symbol in $symbolsParam
do
  # Remove prefix '*' if persent
  if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
    #echo $symbol 
    symbol=$(echo "$symbol" | cut -b 2-6)
    #echo $symbol 
  fi
  ID_NOTATION=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 3)
  SYMBOL_NAME=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 2)
  echo $symbol $SYMBOL_NAME:ID_NOTATION=$ID_NOTATION

  curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -ioF "Mio.&nbsp;EUR<"
done