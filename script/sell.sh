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
export txFee

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Pieces has to be without dot
# shellcheck disable=SC2001
sellPiecesParam=$(echo "$2" | sed 's/\.//g')

# Sell Price has to be without comma -> replace comma with dot
# shellcheck disable=SC2001
sellPriceParam=$(echo "$3" | sed 's/,/./g')

echo "Sell $symbolParam $sellPiecesParam $sellPriceParam"

if { [ -z "$symbolParam" ] || [ -z "$sellPiecesParam" ] || [ -z "$sellPriceParam" ]; } then
    echo "Not all parameters specified!"
    echo "Call: sh ./sell.sh SYMBOL SELLPIECES SELLPRICE"
    echo "Example: sh ./sell.sh BEI 100 9.99"
    exit 1
fi

if { [ "$4" ]; } then
    echo "Too many parameters specified!"
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
# shellcheck disable=SC2001
SYMBOL_NAME=$(echo "$SYMBOL_NAME" | sed 's/"//g')
# SYMBOL_NAME has to be without blank ' ' -> replace with dash '-'
# shellcheck disable=SC2001
SYMBOL_NAME=$(echo "$SYMBOL_NAME" | sed 's/ /-/g')
AVG_PRICE=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f2 -d ' ')
BUY_TOTAL_AMOUNT=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f5 -d ' ' | sed 's/€//g')
TOTAL_PIECES=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f4 -d ' ')

# Fees
CalculateTxFee "$sellPriceParam" "$sellPiecesParam"

# Remove symbol from own list
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

if [ "${TOTAL_PIECES}" = "$sellPiecesParam" ]; then
    echo "Sell all: $TOTAL_PIECES pieces"
    # Add symbol in front of overall list
    sed -i "0,/^/s//$symbolParam /" "$STOCK_SYMBOLS_FILE"
    SELL_AMOUNT=$(echo "$sellPiecesParam $sellPriceParam $BUY_TOTAL_AMOUNT" | awk '{print ($1 * $2) - $3}')
    SELL_AMOUNT=$(echo "$SELL_AMOUNT" | cut -f 1 -d '.')
    SELL_AMOUNT=$((SELL_AMOUNT - txFee))
    winPercentage=$(echo "scale=1; ($SELL_AMOUNT *100 / $BUY_TOTAL_AMOUNT)" | bc)
else
    echo "Sell partial: $sellPiecesParam pieces"
    SELL_AMOUNT=$(echo "$sellPiecesParam $sellPriceParam $AVG_PRICE $sellPiecesParam" | awk '{print ($1 * $2) - ($3 * $4)}')
    SELL_AMOUNT=$(echo "$SELL_AMOUNT" | cut -f 1 -d '.')
    SELL_AMOUNT=$((SELL_AMOUNT - txFee))
    winPercentage=$(echo "scale=1; ($sellPriceParam *100 / $AVG_PRICE) - 100" | bc)

    today=$(date --date="-0 day" +"%Y-%m-%d")
    totalAmountOfPieces=$((TOTAL_PIECES - sellPiecesParam))
    summe=$(echo "$totalAmountOfPieces $AVG_PRICE" | awk '{print $1 * $2}')
    summe=${summe%.*}
    # shellcheck disable=SC2027,SC1003,SC2086
    sed -i '1 i\'$symbolParam' '$AVG_PRICE' '$today' '$totalAmountOfPieces' '$summe'€ '$SYMBOL_NAME'' "$OWN_SYMBOLS_FILE"
fi

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null

# Delete readable file
rm -rf "$OWN_SYMBOLS_FILE"
echo ""

# Write sell/SYMBOL_DATE file
transactionSymbolLastDateFile="sell/""$symbolParam".txt
commaListTransaction=$(cut -f 1-86 -d ' ' < "$transactionSymbolLastDateFile")
echo "$commaListTransaction" "{x:1,y:$sellPriceParam,r:10}, " > sell/"$symbolParam".txt

today=$(date --date="-0 day" +"%Y-%m-%d")

# Write Tx History
echo "Win: $SELL_AMOUNT€"
# 2022-04-23	999€	20%	BEI "BEIERSDORF"
echo "&nbsp;$today	<span>$SELL_AMOUNT&euro;</span>	$winPercentage%	<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbolParam.html' target='_blank'>$symbolParam	\"$SYMBOL_NAME\"</a><br>" | tee -a "$TRANSACTION_HISTORY_FILE"
echo ""

rm -rf "$OUT_TRANSACTION_HISTORY_HTML_FILE"
TRANSACTION_HISTORY_HTML_FILE_HEADER="<!DOCTYPE html><html lang='en'>
<head>
<meta charset='utf-8' />
<meta http-equiv='cache-control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='pragma' content='no-cache' />
<meta http-equiv='expires' content='0' />
<link rel='shortcut icon' type='image/ico' href='favicon.ico' />
<link rel='stylesheet' href='_result.css' />
<script type='text/javascript' src='_common.js'></script>
<script type='text/javascript' src='_result.js'></script>
<title>Performance SA $(date +%Y)</title>
<style type="text/css">
span {text-align:right;display:inline-block;width:90px;font-size:larger;}
</style>
</head>
<body>
<div>"
echo "$TRANSACTION_HISTORY_HTML_FILE_HEADER" > "$OUT_TRANSACTION_HISTORY_HTML_FILE"

TEMP_DIR=/dev/shm/
rm -rf $TEMP_DIR/tmp.*
TEMP_REVERS_FILE="$(mktemp -p $TEMP_DIR)"
TEMP_TRANSACTION_HISTORY_FILE="$(mktemp -p $TEMP_DIR)"

sed 's/<span>//g' "$TRANSACTION_HISTORY_FILE" >> "$TEMP_TRANSACTION_HISTORY_FILE"

lineFromFile=$(grep -F "_blank" "$TEMP_TRANSACTION_HISTORY_FILE")
# 2022-04-23	999€	20%	BEI "BEIERSDORF"
priceFromFile=$(echo "$lineFromFile" | cut -f 2)
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')
echo "&nbsp;Performance SA $(date +%Y)<br><br>&nbsp;Sum before Tax: $summe€<br><br>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

# shellcheck disable=SC2086
awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' $TRANSACTION_HISTORY_FILE* > "$TEMP_REVERS_FILE"
cat -ev "$TEMP_REVERS_FILE" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
rm -rf "$TEMP_REVERS_FILE"
rm -rf "$TEMP_TRANSACTION_HISTORY_FILE"

echo "<br>&nbsp;Sum before Tax: $summe€" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

GetCreationDate
# shellcheck disable=SC2154
echo "<br><br>&nbsp;Good Luck! $creationDate" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

echo "<br></div></body></html>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

TEMP_FILE="$(mktemp -p $TEMP_DIR)"
sed 's/\$/\<br>/g' "$OUT_TRANSACTION_HISTORY_HTML_FILE" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$OUT_TRANSACTION_HISTORY_HTML_FILE"
rm -rf "$TEMP_FILE"

# Increment Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
count=$((count + 1))
rm -rf "$TRANSACTION_COUNT_FILE"
echo "$count" >> "$TRANSACTION_COUNT_FILE"
#echo "Transactions: $count (Year 2025)"
echo "Transactions: $count (Year $(date +%Y))"
#echo "Quali Phase: 01.04. bis 30.09. and"
#echo "Quali Phase: 01.10. bis 31.03."

if [ ! "$(uname)" = 'Linux' ]; then
    echo ""
    echo "Windows:Red Sell-Marker appears in HTML next time Git 'Nightly Action' runs!"
fi
