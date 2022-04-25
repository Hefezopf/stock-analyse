#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt
# and
# Adding Tx to config/transaction_history.txt

# Call: sh ./script/sell.sh SYMBOL SELLPRICE
# Example: sh ./script/sell.sh BEI 9.99
# alias sell='/d/code/stock-analyse/script/sell.sh $1 $2'
# {"event_type": "sell", "client_payload": {"symbol": "BEI", "sellPrice": "9.99"}}

# Import
# shellcheck disable=SC1091
. ./script/constants.sh
. ./script/functions.sh

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
    echo "Call: sh ./buy.sh SYMBOL SELLPRICE"
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

# Fees
CalculateTxFee "$TOTAL_PIECES" "$BUY_TOTAL_AMOUNT"
SELL_TOTAL_AMOUNT=$((SELL_TOTAL_AMOUNT - txFee))

# Remove symbol from own list
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null

# Delete readable file
rm -rf "$OWN_SYMBOLS_FILE"
echo ""

# Write sell/SYMBOL_DATE file
lastDateInDataFile=$(head -n1 data/"$symbolParam".txt | cut -f 1)
transactionSymbolLastDateFile="sell/""$symbolParam"_"$lastDateInDataFile".txt
commaListTransaction=$(cut -d ' ' -f 1-86 < "$transactionSymbolLastDateFile")
rm sell/"$symbolParam"_"$lastDateInDataFile".txt
echo "$commaListTransaction" "{x:1,y:$sellPriceParam,r:10}, " > sell/"$symbolParam"_"$lastDateInDataFile".txt

today=$(date --date="-0 day" +"%Y-%m-%d")

# Write Tx History
echo "Win: $SELL_TOTAL_AMOUNT€"
# BEI	2022-04-23	352	SELL	"BEIERSDORF"
echo "$symbolParam	$today	$SELL_TOTAL_AMOUNT	SELL	$SYMBOL_NAME" | tee -a "$TRANSACTION_HISTORY_FILE"
echo ""

# Increment Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
count=$((count + 1))
rm -rf "$TRANSACTION_COUNT_FILE"
echo "$count" >> "$TRANSACTION_COUNT_FILE"
echo "Transactions: $count (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
