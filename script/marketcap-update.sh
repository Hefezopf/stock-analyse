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
  # Remove prefix '*', if present
  if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
    symbol=$(echo "$symbol" | cut -b 2-6)
  fi
  lineFromTickerFile=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE")
  SYMBOL_NAME=$(echo "$lineFromTickerFile" | cut -f 2)
  ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
  EXCHANGE=$(echo "$lineFromTickerFile" | cut -f 8)
  if [ ! "$EXCHANGE" ]; then # Default = XETRA
    #EXCHANGE="XFRA" # Frankfurt
    EXCHANGE="XETRA"
  fi

  echo ""
  echo $symbol ...

  # Mrd.
  curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
  marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
  if [ "$marktkap" ]; then
    echo "$symbol Market Cap:$marktkap Mrd.€"
  else
    # Bil.
    marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
    if [ "$marktkap" ]; then
        marktkap=$(echo "$marktkap"000"")
        echo "$symbol Market Cap:$marktkap Mrd.€"
    else
        marktkap="?"
        marktkapErrorSymbols=$(echo "$symbol $marktkapErrorSymbols")
        echo "--> ERROR Market Cap: $symbol $ID_NOTATION -> Not Found, ETF or Market Cap too small! $marktkap"
    fi
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap/g" "$TICKER_NAME_ID_FILE"

  # Branche
  branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | cut -f1 -d">" | cut -c 3-)
  if [ "$branche" ]; then
      # Replace ' /' with ',', because error with linux
      branche=$(echo $branche | sed "s/ \//,/g")  
      echo "$symbol Branche: $branche"
  else
    # Branche ><
    branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | cut -f1 -d"<" | cut -c 2-)
    if [ "$branche" ]; then
      # Replace ' /' with ',', because error with linux
      branche=$(echo $branche | sed "s/ \//,/g")    
      branche=$(echo \""$branche\"")
      echo "$symbol Branche: $branche"
    else
      branche="?"
      brancheErrorSymbols=$(echo "$symbol $brancheErrorSymbols")
      echo "--> ERROR Branche: $symbol $ID_NOTATION! $branche"
    fi
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche/g" "$TICKER_NAME_ID_FILE"

  # KGVe
  kgve=$(echo "$curlResponse" | grep -A1 ">KGVe<" | tail -n 1 | cut -f2 -d"<" | cut -f1 -d"," | cut -c 4-)
  if [ "$kgve" ]; then
      echo "$symbol KGVe: $kgve"
  else
    kgve="?"
    kgveErrorSymbols=$(echo "$symbol $kgveErrorSymbols")
    echo "--> ERROR KGVe: $symbol $ID_NOTATION! $kgve"
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve/g" "$TICKER_NAME_ID_FILE"

  # DIVe
  dive=$(echo "$curlResponse" | grep -A1 ">DIVe<" | tail -n 1 | cut -f2 -d"<" | cut -f1 -d","  | cut -c 4-)
  if [ "$dive" ]; then
      # Replace ',' with '.'
      dive=$(echo $dive | sed "s/,/./g")  
      echo "$symbol DIVe: $dive%"
  else
    dive="?"
    diveErrorSymbols=$(echo "$symbol $diveErrorSymbols")
    echo "--> ERROR DIVe: $symbol $ID_NOTATION! $dive"
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$EXCHANGE/g" "$TICKER_NAME_ID_FILE"

  # Spread
  spread=$(echo "$curlResponse" | grep -A1 ">Spread<" | tail -n 1 | cut -f2 -d">" | cut -f1 -d",")
  if [ "$spread" ]; then
      # Replace ',' with '.'
      #spread=$(echo $spread | sed "s/,/./g")  
      echo "$symbol Spread: $spread.xx%"
      if [ "$spread" -gt 1 ]; then
        highSpreadSymbols=$(echo "$symbol $highSpreadSymbols")
      fi
  else
    spread="?"
    spreadErrorSymbols=$(echo "$symbol $spreadErrorSymbols")
    echo "--> ERROR Spread: $symbol $ID_NOTATION! $spread"
  fi


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
if [ "$diveErrorSymbols" ]; then
    echo ""
    echo "Symbols with DIVe Error: diveErrorSymbols=$diveErrorSymbols"
fi
if [ "$spreadErrorSymbols" ]; then
    echo ""
    echo "Symbols with Spread Error: spreadErrorSymbols=$spreadErrorSymbols"
fi
if [ "$highSpreadSymbols" ]; then
    echo ""
    echo "Symbols with HIGH Spread: highSpreadSymbols=$highSpreadSymbols"
fi


