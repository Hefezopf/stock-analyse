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

START_TIME_MEASUREMENT=$(date +%s);

#mem
mkdir -p "$TEMP_DIR/config"
cp "$TICKER_NAME_ID_FILE" "$TEMP_DIR/config"
#mem


# for symbol in $symbolsParam
# do
# urls=$(echo "$urls" | awk 'BEGIN{FS="\t"} {print $3}')
#     urls=($urls 'https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=46671380' 'https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=46671167')
#     outs=('UPAB.html' 'BOX.html')
# done


for symbol in $symbolsParam
do
  if [ "${symbol::1}" = '*' ]; then
  #if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
   # symbol=$(echo "$symbol" | cut -b 2-7)
    symbol="${symbol:1:7}"
  fi
 # lineFromTickerFile=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE") #mem
  lineFromTickerFile=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE_MEM") #mem
  NAME=$(echo "$lineFromTickerFile" | cut -f 2) #| cut -f
  #NAME=$(echo "$lineFromTickerFile" | awk '{ print $2; }')
  #ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3) #| cut -f
  ID_NOTATION=$(echo "$lineFromTickerFile" | awk 'BEGIN{FS="\t"} {print $3}')
  #ASSET_TYPE=$(echo "$lineFromTickerFile" | cut -f 9) #| cut -f
  ASSET_TYPE=$(echo "$lineFromTickerFile" | awk 'BEGIN{FS="\t"} {print $9}')
#echo "--------:$ID_NOTATION"
#echo "--------:$ASSET_TYPE"


# urls=('https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=46671380' 'https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=46671167')
# outs=('UPAB.html' 'BOX.html')
# for i in "${!urls[@]}"; 
# do  
#     curl -c "'$COOKIES_FILE'" -s --location --request GET ${urls[$i]} -o ${outs[$i]} &
# done
# wait
# exit



  if [ ! "$ASSET_TYPE" ]; then
    echo ""
    echo "Error: Unknown Symbol:$symbol"
    exit 2
  fi

#   if [ ! "$ASSET_TYPE" ]; then # Default = STOCK
#     #ASSET_TYPE="INDEX" # STOCK/COIN/INDEX
#     ASSET_TYPE="STOCK"
#   fi

  echo ""
  echo "$symbol" "$NAME" ...

  if [ "$ASSET_TYPE" = 'COIN' ]; then
    echo "Skip -->$ASSET_TYPE"
  fi
  
  if [ "$ASSET_TYPE" = 'INDEX' ]; then
    #curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")
    
    
    curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/etfs/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" &)
    wait


    marktkap="1000"
    branche="\"Strategie\""
    kgve="0"
    dive="0"
    hauptversammlung="?"
    firmenportrait=$(echo "$curlResponse" | grep -F -A2 "\"paragraph\"" | tail -n 2)
    if [ "$firmenportrait" ]; then
        firmenportrait=$(echo "$firmenportrait" | sed "s/\// /g")
        # shellcheck disable=SC2001
        firmenportrait=$(echo "$firmenportrait" | sed "s/\&/ u. /g")
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/\n/ /g")
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/    / /g")
        firmenportrait=${firmenportrait::-2}
        # shellcheck disable=SC2116
        firmenportrait=$(echo \""$firmenportrait\"")
        echo "Firmenportrait: $firmenportrait"
    else
        firmenportrait="-------------"
        firmenportraitErrorSymbols="$symbol $firmenportraitErrorSymbols"
        echo "--> ERROR Firmenportrait: $symbol $ID_NOTATION! $firmenportrait"
    fi    

    # Now write all results in file!
    # Replace till end of line: idempotent!
    sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE_MEM"
  fi  

  if [ "$ASSET_TYPE" = 'STOCK' ]; then
    # Mrd. Market Cap
    #curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION")

    curlResponse=$(curl -c "'$COOKIES_FILE'" -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" &)
    wait

    #marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d "," | cut -c 2-) #| cut -c
    #marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d ",") #| cut -f
    #marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*' | awk 'BEGIN{FS=","} {print $1}')
    marktkap=$(echo "$curlResponse" | grep -m1 "#160;Mrd.&nbsp;EUR<" | grep -o '>.*')
#echo "-----0marktkap:$marktkap"
    marktkap=${marktkap%*,*} # cut suffix inclunding ','
#echo "-----1marktkap:$marktkap"
    marktkap="${marktkap:1}"
#echo "-----2marktkap:$marktkap"

    if [ "$marktkap" ]; then
        echo "Market Cap:$marktkap Mrd.€"
    else
        # Bil. Market Cap
       # marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d "," | cut -c 2-) #| cut -c
        #marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | cut -f1 -d ",")
        #marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*' | awk 'BEGIN{FS=","} {print $1}')
        marktkap=$(echo "$curlResponse" | grep -m1 "#160;Bil.&nbsp;EUR<" | grep -o '>.*')
        marktkap=${marktkap%*,*}
        marktkap="${marktkap:1}"
        if [ "$marktkap" ]; then
            marktkap="${marktkap}000"
            echo "Market Cap:$marktkap Mrd.€"
        else
            marktkap="?"
            marktkapErrorSymbols="$symbol $marktkapErrorSymbols"
            echo "--> ERROR Market Cap: $symbol $ID_NOTATION -> Not Found, INDEX, COIN or Market Cap too small! $marktkap"
        fi
    fi

    # Branche
    #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | cut -f1 -d ">" | cut -c 3-) #| cut -c
    #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | cut -f1 -d ">") #| cut -f
    #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*' | awk 'BEGIN{FS=">"} {print $1}')
    branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o 'e=.*')
    branche=${branche%*"\""*}\"
    branche="${branche:2}"
    if [ "$branche" ]; then
        # Replace ' /' with ',', because error with linux
        branche=$(echo "$branche" | sed "s/ \//,/g")
        echo "Branche: $branche"
    else
        # Branche ><
        #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | cut -f1 -d "<" | cut -c 2-) #| cut -c
        #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | cut -f1 -d "<")
        #branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o '>.*' | awk 'BEGIN{FS="<"} {print $1}')
        branche=$(echo "$curlResponse" | grep -F -A1 ">Branche<" | tail -n 1 | grep -o '>.*')
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
            brancheErrorSymbols="$symbol $brancheErrorSymbols"
            echo "--> ERROR Branche: $symbol $ID_NOTATION! $branche"
        fi
    fi

    # KGVe
    #kgve=$(echo "$curlResponse" | grep -F -A1 ">KGVe<" | tail -n 1 | cut -f2 -d "<" | cut -f1 -d "," | cut -c 4-) #| cut -c
    #kgve=$(echo "$curlResponse" | grep -F -A1 ">KGVe<" | tail -n 1 | cut -f2 -d "<" | cut -f1 -d ",") #| cut -f
    #kgve=$(echo "$curlResponse" | grep -F -A1 ">KGVe<" | tail -n 1 | cut -f2 -d "<" | awk 'BEGIN{FS=","} {print $1}')
    #kgve=$(echo "$curlResponse" | grep -F -A1 ">KGVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}' | awk 'BEGIN{FS=","} {print $1}')
    kgve=$(echo "$curlResponse" | grep -F -A1 ">KGVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}')
    kgve=${kgve%*,*}
    kgve="${kgve:3}"
    if [ "$kgve" ]; then
        echo "KGVe: $kgve"
    else
        kgve="?"
        kgveErrorSymbols="$symbol $kgveErrorSymbols"
        echo "--> ERROR KGVe: $symbol $ID_NOTATION! $kgve"
    fi

    # DIVe
    #dive=$(echo "$curlResponse" | grep -F -A1 ">DIVe<" | tail -n 1 | cut -f2 -d "<" | cut -f1 -d "," | cut -c 4-) #| cut -c
    #dive=$(echo "$curlResponse" | grep -F -A1 ">DIVe<" | tail -n 1 | cut -f2 -d "<" | cut -f1 -d ",") #| cut -f
    #dive=$(echo "$curlResponse" | grep -F -A1 ">DIVe<" | tail -n 1 | cut -f2 -d "<" | awk 'BEGIN{FS=","} {print $1}')
    #dive=$(echo "$curlResponse" | grep -F -A1 ">DIVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}' | awk 'BEGIN{FS=","} {print $1}')
    dive=$(echo "$curlResponse" | grep -F -A1 ">DIVe<" | tail -n 1 | awk 'BEGIN{FS="<"} {print $2}')
    dive=${dive%*,*}
    dive="${dive:3}"
    if [ "$dive" ]; then
        # Replace ',' with '.'
        # shellcheck disable=SC2001 
        dive=$(echo "$dive" | sed "s/,/./g")
        echo "DIVe: $dive%"
    else
        dive="?"
        diveErrorSymbols="$symbol $diveErrorSymbols"
        echo "--> ERROR DIVe: $symbol $ID_NOTATION! $dive"
    fi

    # Hauptversammlung
    #hauptversammlung=$(echo "$curlResponse" | grep -B1 -m1 "Hauptversammlung" | head -n 1 | cut -f2 -d ">" | cut -f1 -d "<") #| cut -f
    #hauptversammlung=$(echo "$curlResponse" | grep -B1 -m1 "Hauptversammlung" | head -n 1 | cut -f2 -d ">" | awk 'BEGIN{FS="<"} {print $1}')
    #hauptversammlung=$(echo "$curlResponse" | grep -B1 -m1 "Hauptversammlung" | head -n 1 | awk 'BEGIN{FS=">"} {print $2}' | awk 'BEGIN{FS="<"} {print $1}')
    hauptversammlung=$(echo "$curlResponse" | grep -B1 -m1 "Hauptversammlung" | head -n 1 | awk 'BEGIN{FS=">"} {print $2}')
    hauptversammlung=${hauptversammlung%*"<"*}
    if [ "$hauptversammlung" ]; then
        echo "Hauptversammlung: $hauptversammlung"
        if [ "$hauptversammlung" ]; then
            hauptversammlungSymbols="$symbol $hauptversammlungSymbols"
        fi
    else
        hauptversammlung="?"
    #   hauptversammlungErrorSymbols="$symbol $hauptversammlungErrorSymbols"
    #   echo "--> ERROR Hauptversammlung: $symbol $ID_NOTATION! $hauptversammlung"
    fi

    # Firmenportrait
    #firmenportrait=$(echo "$curlResponse" | grep -F -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | cut -f2 -d ">" | cut -f1 -d "<") #| cut -f
    #firmenportrait=$(echo "$curlResponse" | grep -F -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | cut -f2 -d ">" | awk 'BEGIN{FS="<"} {print $1}')
#    firmenportrait=$(echo "$curlResponse" | grep -F -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | awk 'BEGIN{FS=">"} {print $2}' | awk 'BEGIN{FS="<"} {print $1}')
    firmenportrait=$(echo "$curlResponse" | grep -F -A1 "inner-spacing--medium-left inner-spacing--medium-right" | tail -n2 | awk 'BEGIN{FS=">"} {print $2}')

#echo "-----0firmenportrait:$firmenportrait"
    firmenportrait=${firmenportrait%*"<"*}
#echo "-----1firmenportrait:$firmenportrait"


    if [ "$firmenportrait" ]; then
        firmenportrait=$(echo "$firmenportrait" | sed "s/\// /g")
        # shellcheck disable=SC2001
        firmenportrait=$(echo "$firmenportrait" | sed "s/\&/ u. /g")
        firmenportrait=$(echo "$firmenportrait" | sed -z "s/\n/ /g")
        echo "Firmenportrait: $firmenportrait"
    else
        firmenportrait="-------------"
        firmenportraitErrorSymbols="$symbol $firmenportraitErrorSymbols"
        echo "--> ERROR Firmenportrait: $symbol $ID_NOTATION! $firmenportrait"
    fi
    # shellcheck disable=SC2116
    firmenportrait=$(echo \""$firmenportrait\"")

    # Now write all results in file!
    # Replace till end of line: idempotent!
    #sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE" #mem
    sed -i "s/$ID_NOTATION.*/$ID_NOTATION\t$marktkap\t$branche\t$kgve\t$dive\t$hauptversammlung\t$ASSET_TYPE\t$firmenportrait/g" "$TICKER_NAME_ID_FILE_MEM"

    # Spread
    #spread=$(echo "$curlResponse" | grep -F -A1 ">Spread<" | tail -n 1 | cut -f2 -d ">" | cut -f1 -d ",") #| cut -f
    #spread=$(echo "$curlResponse" | grep -F -A1 ">Spread<" | tail -n 1 | cut -f2 -d ">" | awk 'BEGIN{FS=","} {print $1}')
    #spread=$(echo "$curlResponse" | grep -F -A1 ">Spread<" | tail -n 1 | awk 'BEGIN{FS=">"} {print $2}' | awk 'BEGIN{FS=","} {print $1}')
    spread=$(echo "$curlResponse" | grep -F -A1 ">Spread<" | tail -n 1 | awk 'BEGIN{FS=">"} {print $2}')
    spread=${spread%*,*}
    if [ "$spread" ]; then
        echo "Spread: $spread.xx%"
        if [ "$spread" -gt 1 ]; then
            highSpreadSymbols="$symbol $highSpreadSymbols"
        fi
    else
        spread="?"
        spreadErrorSymbols="$symbol $spreadErrorSymbols"
        echo "--> ERROR Spread: $symbol $ID_NOTATION! $spread"
    fi
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
#sed -i ':a;N;$!ba;s/\r\tSTOCK/\?\tSTOCK/g' "$TICKER_NAME_ID_FILE" #mem
sed -i ':a;N;$!ba;s/\r\tSTOCK/\?\tSTOCK/g' "$TICKER_NAME_ID_FILE_MEM"

cp "$TICKER_NAME_ID_FILE_MEM" "config" #mem

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."