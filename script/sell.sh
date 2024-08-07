#!/bin/bash

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt
# and
# Adding Tx to config/transaction_history.txt
#
# Call: . script/sell.sh SYMBOL SELLPRICE
# Example: . script/sell.sh BEI 9.99
# alias sell='/d/code/stock-analyse/script/sell.sh $1 $2'
# {"event_type": "sell", "client_payload": {"symbol": "BEI", "sellPrice": "9.99"}}

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

# Fix for warning: referenced but not assigned
export txFee

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Sell Price has to be without comma
# shellcheck disable=SC2001
sellPriceParam=$(echo "$2" | sed 's/,/./g')

echo "Sell $symbolParam $sellPriceParam"

if { [ -z "$symbolParam" ] || [ -z "$sellPriceParam" ]; } then
    echo "Not all parameters specified!"
    echo "Call: sh ./sell.sh SYMBOL SELLPRICE"
    echo "Example: sh ./sell.sh BEI 9.99"
    exit 1
fi

# Add symbol in front of overall list
sed -i "0,/^/s//$symbolParam /" "$STOCK_SYMBOLS_FILE"

# Encrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null

# Read symbol and amount
SYMBOL_NAME=$(grep -m1 -P "$symbolParam\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
BUY_TOTAL_AMOUNT=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f5 -d ' ' | sed 's/€//g')
#BUY_TOTAL_AMOUNT=$(echo "$BUY_TOTAL_AMOUNT" | sed 's/€//g')
TOTAL_PIECES=$(grep -m1 -P "$symbolParam " "$OWN_SYMBOLS_FILE" | cut -f4 -d ' ')
SELL_TOTAL_AMOUNT=$(echo "$sellPriceParam $TOTAL_PIECES $BUY_TOTAL_AMOUNT" | awk '{print ($1 * $2) - $3}')
SELL_TOTAL_AMOUNT=$(echo "$SELL_TOTAL_AMOUNT" | cut -f 1 -d '.')

# Fees
CalculateTxFee "$sellPriceParam" "$TOTAL_PIECES"
SELL_TOTAL_AMOUNT=$((SELL_TOTAL_AMOUNT - txFee))

# Remove symbol from own list
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null

# Delete readable file
rm -rf "$OWN_SYMBOLS_FILE"
echo ""

# Write sell/SYMBOL_DATE file
#lastDateInDataFile=$(head -n1 "$DATA_DIR/$symbolParam".txt | cut -f 1)
#transactionSymbolLastDateFile="sell/""$symbolParam"_"$lastDateInDataFile".txt
transactionSymbolLastDateFile="sell/""$symbolParam".txt
commaListTransaction=$(cut -d ' ' -f 1-86 < "$transactionSymbolLastDateFile")
#rm sell/"$symbolParam"_"$lastDateInDataFile".txt
#echo "$commaListTransaction" "{x:1,y:$sellPriceParam,r:10}, " > sell/"$symbolParam"_"$lastDateInDataFile".txt
echo "$commaListTransaction" "{x:1,y:$sellPriceParam,r:10}, " > sell/"$symbolParam".txt

today=$(date --date="-0 day" +"%Y-%m-%d")

# Write Tx History
echo "Win: $SELL_TOTAL_AMOUNT€"
# 2022-04-23	999€	BEI "BEIERSDORF"
echo "&nbsp;$today	$SELL_TOTAL_AMOUNT&euro;	<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbolParam.html' target='_blank'>$symbolParam	$SYMBOL_NAME</a><br>" | tee -a "$TRANSACTION_HISTORY_FILE"
#echo "&nbsp;<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbolParam.html' target='_blank'>$symbolParam</a>	$today	$SELL_TOTAL_AMOUNT&euro;	$SYMBOL_NAME<br>" | tee -a "$TRANSACTION_HISTORY_FILE"
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
<script type='text/javascript' src='_result.js'></script>
<title>Performance SA 2024</title>
</head>
<body>
<div>"
echo "$TRANSACTION_HISTORY_HTML_FILE_HEADER" > "$OUT_TRANSACTION_HISTORY_HTML_FILE"

lineFromFile=$(grep -F "_blank" "$TRANSACTION_HISTORY_FILE")
# 2022-04-23	999€	BEI "BEIERSDORF"
priceFromFile=$(echo "$lineFromFile" | cut -f 2)
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')
echo "&nbsp;Performance SA 2024<br><br>&nbsp;Sum before Tax: $summe€<br><br>" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"

#TEMP_DIR=/tmp
TEMP_DIR=/dev/shm/
rm -rf $TEMP_DIR/tmp.*
TEMP_REVERS_FILE="$(mktemp -p $TEMP_DIR)"
# shellcheck disable=SC2086
awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' $TRANSACTION_HISTORY_FILE* > "$TEMP_REVERS_FILE"
cat -ev "$TEMP_REVERS_FILE" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
rm -rf "$TEMP_REVERS_FILE"

echo "<br>&nbsp;Sum before Tax: $summe€" >> "$OUT_TRANSACTION_HISTORY_HTML_FILE"
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
echo "Transactions: $count (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
