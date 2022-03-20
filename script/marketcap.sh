#!/usr/bin/env bash

# Call: sh ./script/marketcap.sh SYMBOLS
# Example: sh ./script/marketcap.sh 'BEI VH2' 
# alias ???='/d/code/stock-analyse/script/marketcap.sh $1'

# Market Cap only Mio!: VH2 "FRIEDRICH VORWERK":ID_NOTATION=328873513

#set -x

TICKER_NAME_ID_FILE=config/ticker_name_id.txt
symbolsParam=$1

if  [ -z "$symbolsParam" ]; then
  echo "Not all parameters specified!"
  echo "Call: sh ./script/marketcap.sh SYMBOLS"
  echo "Example: sh ./script/marketcap.sh 'BEI VH2'"
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

  result=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -ioF "#160;Mio.&nbsp;EUR")
#  result=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -ioF "#160;Mio.&nbsp;EUR<")
  if [ "$result" ]; then
    echo Market cap under 1 Mrd. Euro!: $symbol $SYMBOL_NAME:ID_NOTATION=$ID_NOTATION
  fi
done