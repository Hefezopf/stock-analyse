#!/bin/bash

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt
# and
# Adding Tx to config/transaction_history.txt
#
# Call: . script/sell.sh SYMBOL SELLPIECES SELLPRICE
# Example: . script/sell.sh BEI 100 9.99
# alias sell='/d/code/stock-analyse/script/sell.sh $1 $2 $3'
# {"event_type": "sell", "client_payload": {"symbol": "BEI", "sellPieces": "100", "sellPrice": "9.99"}}

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

# Fix for warning: referenced but not assigned
export TX_FEE

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Pieces has to be without dot
sellPiecesParam=$2
sellPiecesParam="${sellPiecesParam//\./}"

# Sell Price has to be without comma -> replace comma with dot
sellPriceParam=$3
sellPriceParam="${sellPriceParam//,/.}"

echo "Sell $symbolParam $sellPiecesParam $sellPriceParam"

if { [ -z "$symbolParam" ] || [ -z "$sellPiecesParam" ] || [ -z "$sellPriceParam" ]; } then
    echo "Error: Not all parameters specified!"
    echo "Call: sh ./sell.sh SYMBOL SELLPIECES SELLPRICE"
    echo "Example: sh ./sell.sh BEI 100 9.99"
    exit 1
fi

if { [ "$4" ]; } then
    echo "Error: Too many parameters specified!"
    echo "Call: sh ./sell.sh SYMBOL SELLPIECES SELLPRICE"
    echo "Example: sh ./sell.sh BEI 100 9.99"
    exit 2
fi

if [ "${symbolParam::1}" = '*' ]; then
    symbolParam="${symbolParam:1:7}"
fi

# Encrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null

# Read symbol and amount
SYMBOL_NAME=$(grep -m1 -P "$symbolParam\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
# SYMBOL_NAME has to be without Hochkomma '"'
SYMBOL_NAME="${SYMBOL_NAME//\"/}"

# SYMBOL_NAME has to be without blank ' ' -> replace with dash '-'
SYMBOL_NAME="${SYMBOL_NAME// /-}"
AVG_PRICE=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f2 -d ' ')
BUY_TOTAL_AMOUNT=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f5 -d ' ' | sed 's/€//g')
TOTAL_PIECES=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f4 -d ' ')

if { [ -z "$TOTAL_PIECES" ]; } then
    echo "Error: Stock Symbol $symbolParam not in portfolio!"
    exit 3
fi

# Fees
CalculateTxFee "$sellPriceParam" "$sellPiecesParam"

# Remove symbol from own list
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

if [ "${TOTAL_PIECES}" = "$sellPiecesParam" ]; then
    echo "Sell all: $TOTAL_PIECES pieces"
    # Add symbol in front of overall list
    sed -i "0,/^/s//$symbolParam /" "$STOCK_SYMBOLS_FILE"
    WIN_AMOUNT=$(echo "$sellPiecesParam $sellPriceParam $BUY_TOTAL_AMOUNT" | awk '{print ($1 * $2) - $3}')
    WIN_AMOUNT=$(echo "$WIN_AMOUNT" | cut -f 1 -d '.')
    WIN_AMOUNT=$((WIN_AMOUNT - TX_FEE))
    winPercentage=$(echo "scale=1; ($WIN_AMOUNT *100 / $BUY_TOTAL_AMOUNT)" | bc)
else
    newPiecesAmount=$((TOTAL_PIECES - sellPiecesParam))
    echo "Sell partial: $sellPiecesParam pieces"
    echo "Now: $newPiecesAmount pieces in portfolio"

    WIN_AMOUNT=$(echo "$sellPiecesParam $sellPriceParam $AVG_PRICE $sellPiecesParam" | awk '{print ($1 * $2) - ($3 * $4)}')
    WIN_AMOUNT=$(echo "$WIN_AMOUNT" | cut -f 1 -d '.')
    WIN_AMOUNT=$((WIN_AMOUNT - TX_FEE))

    newAmount=$(echo "$BUY_TOTAL_AMOUNT $sellPiecesParam $sellPriceParam" | awk '{print $1 - ($2 * $3)}')

    if [ "$(uname)" = 'Linux' ]; then
        echo ""
    else
        echo "$newAmount" | clip
    fi
    
    winPercentage=$(echo "scale=1; ($sellPriceParam *100 / $AVG_PRICE) - 100" | bc)
 
    today=$(date --date="-0 day" +"%Y-%m-%d")
    totalAmountOfPieces=$((TOTAL_PIECES - sellPiecesParam))
    summe=$(echo "$totalAmountOfPieces $AVG_PRICE" | awk '{print $1 * $2}')
    summe=${summe%.*}
    # shellcheck disable=SC2027,SC1003,SC2086
    sed -i '1 i\'$symbolParam' '$AVG_PRICE' '$today' '$totalAmountOfPieces' '$summe'€ '$SYMBOL_NAME'' "$OWN_SYMBOLS_FILE"
fi

if [ "${winPercentage:0:1}" = "." ]; then
    winPercentage="0$winPercentage" # Add leading 0
fi

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null

# Delete readable file
rm -rf "$OWN_SYMBOLS_FILE"
#echo ""

# Write sell/SYMBOL_DATE file
transactionSymbolLastDateFile="sell/""$symbolParam".txt
commaListTransaction=$(cut -f 1-86 -d ' ' < "$transactionSymbolLastDateFile")
echo "$commaListTransaction" "{x:1,y:$sellPriceParam,r:10}, " > sell/"$symbolParam".txt

today=$(date --date="-0 day" +"%Y-%m-%d")

# Write Tx History
echo "Win: $WIN_AMOUNT€"
# 2022-04-23	999€	20%	BEI "BEIERSDORF"
echo "<div>&nbsp;$today&#9;$WIN_AMOUNT&#8364;&#9;&nbsp;&#9;$winPercentage%&#9;&nbsp;&#9;<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbolParam.html' target='_blank'>$symbolParam&#9;\"$SYMBOL_NAME\"</a></div>" >> "$TRANSACTION_HISTORY_FILE"
#echo ""

rm -rf "$OUT_TRANSACTION_HISTORY_HTML_FILE"
# shellcheck disable=SC1078
TRANSACTION_HISTORY_HTML_FILE_HEADER="<!DOCTYPE html><html lang='en'>
<head>
<meta charset='utf-8' />
<meta http-equiv='cache-control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='pragma' content='no-cache' />
<meta http-equiv='expires' content='0' />
<link rel='icon' type='image/x-icon' href='favicon.ico' />
<script type='text/javascript' src='_common.js'></script>
<script type='text/javascript' src='_result.js'></script>
<title>Performance SA $(date +%Y)</title>
<style type='text/css'>
div {font-size: x-large; padding-top: 10px;}
</style>

<style type='text/css'>
/* Colors */
.green{color:green;} .red{color:red;} .black{color:black;}

/* .imgborder { border: 1px solid; pointer-events: none;} */
.imgborder { border: 1px solid;} 

/* iPhone 3 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 1) {
    body > div {
        font-size: xx-large;
    }
}
        
/* iPhone 4 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 5 */
@media only screen and (min-device-width: 320px) and (max-device-height: 568px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 6, 6s, 7, 8 */
@media only screen and (min-device-width: 375px) and (max-device-height: 667px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone 6+, 6s+, 7+, 8+ */
@media only screen and (min-device-width: 414px) and (max-device-height: 736px) and (-webkit-device-pixel-ratio: 3) { 
    body > div {
        font-size: xx-large;
    }
}

/* iPhone X, XS, 11 Pro, 12 Mini */
@media only screen and (min-device-width: 375px) and (max-device-height: 812px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro, 14 Mini (Meines 2023) */
@media only screen and (min-device-width: 390px) and (max-device-height: 844px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        width: 25em;
        font-size: xx-large;
    }
}

/* iPhone XR, 11 */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone XS Max, 11 Pro Max */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro Max */
@media only screen and (min-device-width: 428px) and (max-device-height: 926px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 16 (Meines 09/2024) */
@media only screen and (min-device-width: 393px) and (max-device-height: 852px) and (-webkit-device-pixel-ratio: 3) {
    body {
        /* width: 750px; */
        /* width: 150px; */
        font-size: xx-large;
        zoom: 1.6;
        background: blue;
    }
    /*
    body > div > div { 
        font-size: xx-large;
    }
    */
    /* headlineLink */
    body > div > div > div { 
        font-size: xxx-large;
        /* background: green; */
     }     
/*
    #parameterId {
            background: green;
    }

    #headlineLinkId {
            font-size: large;
            background: blue;
    }
*/
}

/* Safari */
@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>


</head>
<body>
<script>var linkMap = new Map();</script>
<div>"
echo "$TRANSACTION_HISTORY_HTML_FILE_HEADER" > "$OUT_TRANSACTION_HISTORY_HTML_FILE"

TEMP_DIR=/dev/shm/
rm -rf $TEMP_DIR/tmp.*
TEMP_REVERS_FILE="$(mktemp -p $TEMP_DIR)"
TEMP_TRANSACTION_HISTORY_FILE="$(mktemp -p $TEMP_DIR)"

sed 's/&#9;/\t/g' "$TRANSACTION_HISTORY_FILE" >> "$TEMP_TRANSACTION_HISTORY_FILE"

lineFromFile=$(grep -F "_blank" "$TEMP_TRANSACTION_HISTORY_FILE")
# 2022-04-23	999€	20%	BEI "BEIERSDORF"
priceFromFile=$(echo "$lineFromFile" | cut -f 2)
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')
count=$(cat "$TRANSACTION_COUNT_FILE")
count=$((count + 1))
echo "&nbsp;Performance SA $(date +%Y)<br><br>&nbsp;Sum before Tax: $summe€<br>&nbsp;Transaction count: $count<br><br>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
echo "<button id='performanceButtonOpenAll' style='font-size:large; height: 60px; width: 110px;' type='button' onClick='javascript:doOpenAllInTab()'>Open All</button><br><br>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

# shellcheck disable=SC2086
awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' $TRANSACTION_HISTORY_FILE* > "$TEMP_REVERS_FILE"
cat -ev "$TEMP_REVERS_FILE" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
rm -rf "$TEMP_REVERS_FILE"
rm -rf "$TEMP_TRANSACTION_HISTORY_FILE"

echo "<br>&nbsp;Sum before Tax: $summe€<br>&nbsp;Transaction count: $count" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

GetCreationDate
# shellcheck disable=SC2154
echo "<br><br>&nbsp;Good Luck! $creationDate<br><br></div><script>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

#echo "symbolParam: $symbolParam"

# shellcheck disable=SC2013
for symbol in $(awk '{print $3}' config/transaction_history.txt | sed "s/'/xxx/g" | sed 's/target\=xxx_blankxxx>//g' | sed 's/&.*//' |awk '!seen[$0]++')
do 
#echo "symbol: $symbol"
    echo "linkMap.set('$symbol', 'https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/""$symbol"".html');" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
done

echo "</script></body></html>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

TEMP_FILE="$(mktemp -p $TEMP_DIR)"
sed 's/\$/\<br>/g' "$OUT_TRANSACTION_HISTORY_HTML_FILE" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$OUT_TRANSACTION_HISTORY_HTML_FILE"
rm -rf "$TEMP_FILE"

# Increment Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
count=$((count + 1))
rm -rf "$TRANSACTION_COUNT_FILE"
echo "$count" >> "$TRANSACTION_COUNT_FILE"
echo "Transaction count: $count (Year $(date +%Y))"

if [ ! "$(uname)" = 'Linux' ]; then
    echo ""
    echo "Windows:Red Sell-Marker appears next time in HTML when Github 'Nightly Action' runs!"
fi
