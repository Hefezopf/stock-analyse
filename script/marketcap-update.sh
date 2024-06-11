#!/bin/bash

# CURL auf die www.comdirect.de Webseite und parsen der Daten.
#
# Call: script/marketcap-update.sh SYMBOLS
# Example: script/marketcap-update.sh 'BEI VH2'
# alias ???='/d/code/stock-analyse/script/marketcap-update.sh $1'

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

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
    symbol=$(echo "$symbol" | cut -b 2-7)
  fi
  lineFromTickerFile=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE")
  NAME=$(echo "$lineFromTickerFile" | cut -f 2)
  ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
  EXCHANGE=$(echo "$lineFromTickerFile" | cut -f 8)
  if [ ! "$EXCHANGE" ]; then # Default = XETRA
    #EXCHANGE="XFRA" # Frankfurt
    EXCHANGE="XETRA"
  fi
  ASSET_TYPE=$(echo "$lineFromTickerFile" | cut -f 10)
  if [ ! "$ASSET_TYPE" ]; then # Default = STOCK
    #ASSET_TYPE="INDEX" # STOCK/COIN/INDEX
    ASSET_TYPE="STOCK"
  fi


  echo ""
  echo "$symbol" "$NAME" ...

if [ "$ASSET_TYPE" = 'STOCK' ]; then
  # Mrd. Market Cap
  curlResponse=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
  marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
  if [ "$marktkap" ]; then
    echo "$symbol Market Cap:$marktkap Mrd.€"
  else
    # Bil. Market Cap
    marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d"," | cut -c 2-)
    if [ "$marktkap" ]; then
        marktkap="${marktkap}000"
        echo "$symbol Market Cap:$marktkap Mrd.€"
    else
        marktkap="?"
        marktkapErrorSymbols="$symbol $marktkapErrorSymbols"
        echo "--> ERROR Market Cap: $symbol $ID_NOTATION -> Not Found, INDEX, COIN or Market Cap too small! $marktkap"
    fi
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap/g" "$TICKER_NAME_ID_FILE"

  # Branche
  branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | cut -f1 -d">" | cut -c 3-)
  if [ "$branche" ]; then
      # Replace ' /' with ',', because error with linux
      branche=$(echo "$branche" | sed "s/ \//,/g")  
      echo "$symbol Branche: $branche"
  else
    # Branche ><
    branche=$(echo "$curlResponse" | grep -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | cut -f1 -d"<" | cut -c 2-)
    if [ "$branche" ]; then
      # Replace ' /' with ',', because error with linux
      branche=$(echo "$branche" | sed "s/ \//,/g")   
      # shellcheck disable=SC2116 
      branche=$(echo \""$branche\"")
      echo "$symbol Branche: $branche"
    else
      branche="?"
      brancheErrorSymbols="$symbol $brancheErrorSymbols"
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
    kgveErrorSymbols="$symbol $kgveErrorSymbols"
    echo "--> ERROR KGVe: $symbol $ID_NOTATION! $kgve"
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve/g" "$TICKER_NAME_ID_FILE"

  # DIVe
  dive=$(echo "$curlResponse" | grep -A1 ">DIVe<" | tail -n 1 | cut -f2 -d"<" | cut -f1 -d","  | cut -c 4-)
  if [ "$dive" ]; then
      # Replace ',' with '.'
      # shellcheck disable=SC2001 
      dive=$(echo "$dive" | sed "s/,/./g")
      echo "$symbol DIVe: $dive%"
  else
    dive="?"
    diveErrorSymbols="$symbol $diveErrorSymbols"
    echo "--> ERROR DIVe: $symbol $ID_NOTATION! $dive"
  fi
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive/g" "$TICKER_NAME_ID_FILE"

  # Hauptversammlung
  hauptversammlung=$(echo "$curlResponse" | grep -B1 -m1 "Hauptversammlung" | head -n 1 | cut -f2 -d">" | cut -f1 -d"<")
  if [ "$hauptversammlung" ]; then
      echo "$symbol Hauptversammlung: $hauptversammlung"
      if [ "$hauptversammlung" ]; then
        hauptversammlungSymbols="$symbol $hauptversammlungSymbols"
      fi
  else
    hauptversammlung="?"
  #   hauptversammlungErrorSymbols="$symbol $hauptversammlungErrorSymbols"
  #   echo "--> ERROR Hauptversammlung: $symbol $ID_NOTATION! $hauptversammlung"
  fi

  # Firmenportrait
  firmenportrait=$(echo "$curlResponse" | grep -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | cut -f2 -d">" | cut -f1 -d"<")
   if [ "$firmenportrait" ]; then
      firmenportrait=$(echo "$firmenportrait" | sed "s/\// /g")
      firmenportrait=$(echo "$firmenportrait" | sed "s/\&/und/g")
      firmenportrait=$(echo "$firmenportrait" | sed -z "s/\n/ /g") 
      echo "$symbol Firmenportrait: $firmenportrait"
   else
    firmenportrait="-------------"
    firmenportraitErrorSymbols="$symbol $firmenportraitErrorSymbols"
    echo "--> ERROR Firmenportrait: $symbol $ID_NOTATION! $firmenportrait"
   fi
   # shellcheck disable=SC2116
   firmenportrait=$(echo \""$firmenportrait\"")

  # Now write all results in file!
  # Replace till end of line: idempotent!
  sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$EXCHANGE\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE"

  # Spread
  spread=$(echo "$curlResponse" | grep -A1 ">Spread<" | tail -n 1 | cut -f2 -d">" | cut -f1 -d",")
  if [ "$spread" ]; then
      echo "$symbol Spread: $spread.xx%"
      if [ "$spread" -gt 1 ]; then
        highSpreadSymbols="$symbol $highSpreadSymbols"
      fi
  else
    spread="?"
    spreadErrorSymbols="$symbol $spreadErrorSymbols"
    echo "--> ERROR Spread: $symbol $ID_NOTATION! $spread"
  fi
else
    echo "-->$ASSET_TYPE"
fi
done

if [ "$marktkapErrorSymbols" ]; then
    echo ""
    echo "Symbols with Market Cap Error: marktkapErrorSymbols=$marktkapErrorSymbols"
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
# if [ "$hauptversammlungErrorSymbols" ]; then
#     echo ""
#     echo "Symbols with Hauptversammlung Error: hauptversammlungErrorSymbols=$hauptversammlungErrorSymbols"
# fi
if [ "$firmenportraitErrorSymbols" ]; then
    echo ""
    echo "Symbols with firmenportrait Error: firmenportraitErrorSymbols=$firmenportraitErrorSymbols"
fi
if [ "$spreadErrorSymbols" ]; then
    echo ""
    echo "Symbols with Spread Error: spreadErrorSymbols=$spreadErrorSymbols"
fi
if [ "$highSpreadSymbols" ]; then
    echo ""
    echo "Symbols with HIGH Spread (Greater 2%): highSpreadSymbols=$highSpreadSymbols"
fi

# Replace CR in Linux
sed -i ':a;N;$!ba;s/\r\tSTOCK/\?\tSTOCK/g' "$TICKER_NAME_ID_FILE"
