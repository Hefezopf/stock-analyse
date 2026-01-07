#!/bin/bash

# CURL auf die www.comdirect.de Webseite und parsen der Daten.
#
# Call: script/marketcap-update.sh SYMBOLS
# Example: script/marketcap-update.sh 'BEI VH2'
# alias mc='/d/code/stock-analyse/script/marketcap-update.sh $1'

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

symbolsParam=$1

if  [ -z "$symbolsParam" ]; then
  echo "Error: Not all parameters specified!"
  echo "Call: sh ./script/marketcap-update.sh SYMBOLS"
  echo "Example: sh ./script/marketcap-update.sh 'BEI VH2'"
  exit 1
fi

START_TIME_MEASUREMENT=$(date +%s);

#mem
mkdir -p "$TEMP_DIR/config"
cp "$TICKER_NAME_ID_FILE" "$TEMP_DIR/config"
#mem

for symbol in $symbolsParam
do
  if [ "${symbol::1}" = '*' ]; then
    symbol="${symbol:1:7}"
  fi
  lineFromTickerFile=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE_MEM") #mem
  NAME=$(echo "$lineFromTickerFile" | cut -f 2) #| cut -f
  ID_NOTATION=$(echo "$lineFromTickerFile" | awk 'BEGIN{FS="\t"} {print $3}')
  ASSET_TYPE=$(echo "$lineFromTickerFile" | awk 'BEGIN{FS="\t"} {print $9}')

  if [ ! "$ASSET_TYPE" ]; then
    echo ""
    echo "Error: Symbol not in config:$symbol"
    exit 2
  fi

  echo ""
  echo "$symbol" "$NAME" ...

  if [ "$ASSET_TYPE" = 'COIN' ]; then
    echo "Skip -->$ASSET_TYPE"
  fi
  
  if [ "$ASSET_TYPE" = 'INDEX' ]; then
    curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
    marktkap="1000"
    branche="\"Strategie\""
    kgve="0"
    dive="0"
    hauptversammlung="?"
    firmenportrait=$(echo "$curlResponse" 2>/dev/null | grep -F -A2 "\"paragraph\"" | tail -n 2)
    if [ "$firmenportrait" ]; then
        firmenportrait="${firmenportrait//\// }"
        firmenportrait="${firmenportrait//\&/ u. }"
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/\n/ /g")
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/    / /g")
        firmenportrait=${firmenportrait::-2}
        # shellcheck disable=SC2116
        firmenportrait=$(echo \""$firmenportrait\"")
        echo "Firmenportrait: $firmenportrait"
    else
        firmenportrait="-------------"
        firmenportraitWarningSymbols="$symbol $firmenportraitWarningSymbols"
        echo "--> Warning Firmenportrait: $symbol $ID_NOTATION! $firmenportrait"
    fi    

    # Now write all results in file!
    # Replace till end of line: idempotent!
    sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE_MEM"
  fi  

  if [ "$ASSET_TYPE" = 'STOCK' ]; then
    # Mrd. Market Cap
    curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
    marktkap=$(echo "$curlResponse" 2>/dev/null | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*')
#echo "-----0marktkap:$marktkap"
    marktkap=${marktkap%*,*} # cut suffix inclunding ','
#echo "-----1marktkap:$marktkap"
    marktkap="${marktkap:1}"
#echo "-----2marktkap:$marktkap"

    if [ "$marktkap" ]; then
        echo "Market Cap:$marktkap Mrd.€"
    else
        # Bil. Market Cap
        marktkap=$(echo "$curlResponse" 2>/dev/null | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*')
        marktkap=${marktkap%*,*}
        marktkap="${marktkap:1}"
        if [ "$marktkap" ]; then
            marktkap="${marktkap}000"
            echo "Market Cap:$marktkap Mrd.€"
        else
            marktkap="?"
            marketkapWarningSymbols="$symbol $marketkapWarningSymbols"
            echo "--> WARNING Market Cap: $symbol $ID_NOTATION -> Not Found, INDEX, COIN or Market Cap too small?! $marktkap"
        fi
    fi

    # Branche
    branche=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*')
    branche=${branche%*"\""*}\"
    branche="${branche:2}"
    if [ "$branche" ]; then
        # Replace ' /' with ',', because error with linux
        branche=$(echo "$branche" | sed "s/ \//,/g")
        echo "Branche: $branche"
    else
        # Branche ><
        branche=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 ">Branche<" | tail -n 1 | grep -o '>.*')
        branche=${branche%*"<"*}
        branche="${branche:1}"
        if [ "$branche" ]; then
            # Replace ' /' with ',', because error with linux
            branche=$(echo "$branche" | sed "s/ \//,/g")
            # shellcheck disable=SC2116 
            branche=$(echo \""$branche\"")
            echo "Branche: $branche"
        else
            branche="?"
            brancheWarningSymbols="$symbol $brancheWarningSymbols"
            echo "--> WARNING Branche: $symbol $ID_NOTATION! $branche"
        fi
    fi

    # KGVe
    kgve=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 ">KGVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}')
    kgve=${kgve%*,*}
    kgve="${kgve:3}"
    if [ "$kgve" ]; then
        echo "KGVe: $kgve"
    else
        kgve="?"
        kgveWarningSymbols="$symbol $kgveWarningSymbols"
        echo "--> WARNING KGVe: $symbol $ID_NOTATION! $kgve"
    fi

    # DIVe
    dive=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 ">DIVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}')
    dive=${dive%*,*}
    dive="${dive:3}"
    if [ "$dive" ]; then
        # Replace ',' with '.'
        dive="${dive//,/.}"
        echo "DIVe: $dive%"
    else
        dive="?"
        diveWarningSymbols="$symbol $diveWarningSymbols"
        echo "--> WARNING DIVe: $symbol $ID_NOTATION! $dive"
    fi

    # Hauptversammlung
    hauptversammlung=$(echo "$curlResponse" 2>/dev/null | grep -B1 -m1 "Hauptversammlung" | head -n 1 | awk 'BEGIN{FS=">"} {print $2}')
    hauptversammlung=${hauptversammlung%*"<"*}
    if [ "$hauptversammlung" ]; then
        echo "Hauptversammlung: $hauptversammlung"
        if [ "$hauptversammlung" ]; then
            hauptversammlungSymbols="$symbol $hauptversammlungSymbols"
        fi
    else
        hauptversammlung="?"
    fi

    # Firmenportrait
    firmenportrait=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | awk 'BEGIN{FS=">"} {print $2}')
    firmenportrait=${firmenportrait%*"<"*}

    if [ "$firmenportrait" ]; then
        firmenportrait="${firmenportrait//\// }"
        firmenportrait="${firmenportrait//\&/ u. }"
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/\n/ /g")
        echo "Firmenportrait: $firmenportrait"
    else
        firmenportrait="-------------"
        firmenportraitWarningSymbols="$symbol $firmenportraitWarningSymbols"
        echo "--> WARNING Firmenportrait: $symbol $ID_NOTATION! $firmenportrait"
    fi
    # shellcheck disable=SC2116
    firmenportrait=$(echo \""$firmenportrait\"")

    # Now write all results in file!
    # Replace till end of line: idempotent!
    sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE_MEM"

    # Spread
    spread=$(echo "$curlResponse" 2>/dev/null | grep -F -A1 ">Spread<" | tail -n 1 | awk 'BEGIN{FS=">"} {print $2}')
    spread=${spread%*,*}
    if [ "$spread" ]; then
        echo "Spread: $spread.xx%"
        if [ "$spread" -gt 1 ]; then
            highSpreadSymbols="$symbol $highSpreadSymbols"
        fi
    else
        spread="?"
        spreadWarningSymbols="$symbol $spreadWarningSymbols"
        echo "--> WARNING Spread: $symbol $ID_NOTATION! $spread"
    fi
  fi
done

if [ "$marketkapWarningSymbols" ]; then
    echo ""
    echo "Symbols with Market Cap Warning: marketkapWarningSymbols=$marketkapWarningSymbols"
fi
if [ "$brancheWarningSymbols" ]; then
    echo ""
    echo "Symbols with Branche Warning: brancheWarningSymbols=$brancheWarningSymbols"
fi
if [ "$kgveWarningSymbols" ]; then
    echo ""
    echo "Symbols with KGVe Warning: kgveWarningSymbols=$kgveWarningSymbols"
fi
if [ "$diveWarningSymbols" ]; then
    echo ""
    echo "Symbols with DIVe Warning: diveWarningSymbols=$diveWarningSymbols"
fi
# if [ "$hauptversammlungWarningSymbols" ]; then
#     echo ""
#     echo "Symbols with Hauptversammlung Warning: hauptversammlungWarningSymbols=$hauptversammlungWarningSymbols"
# fi
if [ "$firmenportraitWarningSymbols" ]; then
    echo ""
    echo "Symbols with firmenportrait Warning: firmenportraitWarningSymbols=$firmenportraitWarningSymbols"
fi
if [ "$spreadWarningSymbols" ]; then
    echo ""
    echo "Symbols with Spread Warning: spreadWarningSymbols=$spreadWarningSymbols"
fi
if [ "$highSpreadSymbols" ]; then
    echo ""
    echo "Symbols with HIGH Spread (Greater 2%): highSpreadSymbols=$highSpreadSymbols"
fi

# Replace CR in Linux
sed -i ':a;N;$!ba;s/\r\tSTOCK/\?\tSTOCK/g' "$TICKER_NAME_ID_FILE_MEM"

cp "$TICKER_NAME_ID_FILE_MEM" "config" #mem

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."