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
  curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
  marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
  if [ "$marktkap" ]; then
    echo "$symbol Market Cap:$marktkap Mrd."
  else
    # Bil.
    marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
    if [ "$marktkap" ]; then
        marktkap=$(echo "$marktkap"000"")
        echo "$symbol Market Cap:$marktkap Mrd."
    else
        marktkap="?"
        marktkapErrorSymbols=$(echo "$symbol $marktkapErrorSymbols")
        echo "ERROR Market Cap: $symbol $ID_NOTATION -> ETF or market cap too small! $marktkap"
    fi
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap/g" "$TICKER_NAME_ID_FILE"

  # Branche
  branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | cut -f1 -d">" | cut -c 3-)
  if [ "$branche" ]; then
      echo "$symbol Branche: $branche"
  else
    # Branche ><
    branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | cut -f1 -d"<" | cut -c 2-)
    if [ "$branche" ]; then
      branche=$(echo \""$branche\"")
      echo "$symbol Branche: $branche"
    else
      branche="?"
      brancheErrorSymbols=$(echo "$symbol $brancheErrorSymbols")
      echo "ERROR Branche: $symbol $ID_NOTATION! $branche"
    fi
  fi
  # Replace ' /' with ',', because error with linux
  branche=$(echo $branche | sed "s/ \//,/g")
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche/g" "$TICKER_NAME_ID_FILE"

  # KGVe
  # ...
  kgve=$(echo "$curlResponse" | grep -A1 ">KGVe<" | tail -n 1 | cut -f2 -d"<" | cut -f1 -d"," | cut -c 4-)
  if [ "$kgve" ]; then
      echo "$symbol KGVe: $kgve"
  else
    kgve="?"
    kgveErrorSymbols=$(echo "$symbol $kgveErrorSymbols")
    echo "ERROR KGVe: $symbol $ID_NOTATION! $kgve"
  fi
  # Replace '.' with '', because readablity
  #kgve=$(echo $kgve | sed "s/\.///g")  
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve/g" "$TICKER_NAME_ID_FILE"

  # DIVe
  # ...

done

if [ "$marktkapErrorSymbols" ]; then
    echo ""
    echo "Symbols with Market Kap Error: marktkapErrorSymbols=$marktkapErrorSymbols"
fi
if [ "$brancheErrorSymbols" ]; then
    echo ""
    echo "Symbols with Branche Error: brancheErrorSymbols=$brancheErrorSymbols"
fi
if [ "$kgveErrorSymbols" ]; then
    echo ""
    echo "Symbols with KGVe Error: kgveErrorSymbols=$kgveErrorSymbols"
fi
