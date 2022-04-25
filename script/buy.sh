#!/bin/sh

# Adding *symbol to config/own_symbols.txt
# and
# Removing symbol from config/stock_symbols.txt
# Covers Rebuy scenario as well!

# Call: sh ./script/buy.sh SYMBOL PIECES PRICE
# Example: sh ./script/buy.sh BEI 100 9.99 
# alias buy='/d/code/stock-analyse/script/buy.sh $1 $2 $3'
# {"event_type": "buy", "client_payload": {"symbol": "BEI", "price": "9.99", "pieces": "100"}}

#set -x

# Import
# shellcheck disable=SC1091
. ./script/constants.sh
. ./script/functions.sh

# Fix for warning: referenced but not assigned
export txFee

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Pieces has to be without dot
piecesParam="${2//\.}"

# Price has to be without comma
priceParam="${3//,/.}"

echo "Buy $symbolParam $piecesParam $priceParam"

if { [ -z "$symbolParam" ] || [ -z "$priceParam" ] || [ -z "$piecesParam" ]; } then
  echo "Not all parameters specified!"
  echo "Call: sh ./buy.sh SYMBOL PIECES PRICE"
  echo "Example: sh ./buy.sh BEI 100 9.99"
  exit 1
fi

summe=$(echo "$priceParam $piecesParam" | awk '{print $1 * $2}')
summe=${summe%.*}

case "$piecesParam" in
    ''|*[!0-9]*) echo "Error: PIECES Not a integer number!" >&2; exit 3 ;;
esac

# Remove from overall list, if not there do nothing
sed -i "s/$symbolParam //" "$STOCK_SYMBOLS_FILE"

# Decript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null

sleep 1

lineFromOwnSymbolsFile=$(grep -m1 -P "$symbolParam" "$OWN_SYMBOLS_FILE")
priceFromOwnSymbolsFile=$(echo "$lineFromOwnSymbolsFile" | cut -f 2 -d' ')
piecesFromOwnSymbolsFile=$(echo "$lineFromOwnSymbolsFile" | cut -f 4 -d' ')
summeFromOwnSymbolsFile=$(echo "$lineFromOwnSymbolsFile" | cut -f 5 -d' ' | sed 's/€//g')
totalAmountOfPieces=$((piecesParam + piecesFromOwnSymbolsFile))

# Rebuy: Remove from own list, if symbol not found -> do nothing
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

# Add symbol in front of own list
SYMBOL_NAME=$(grep -m1 -P "$symbolParam\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
# SYMBOL_NAME has to be without Hochkomma '"'
# shellcheck disable=SC2001
SYMBOL_NAME=$(echo "$SYMBOL_NAME" | sed 's/"//g')
# SYMBOL_NAME has to be without blank ' ' -> replace with dash '-'
# shellcheck disable=SC2001
SYMBOL_NAME=$(echo "$SYMBOL_NAME" | sed 's/ /-/g')

# Fees
CalculateTxFee "$priceParam" "$piecesParam"
summePlusFees=$((summe + txFee))
summe=$((summe - txFee))
pricePlusFees=$(echo "$summePlusFees $piecesParam" | awk '{print $1 / $2}')
summe=$((summe + summeFromOwnSymbolsFile))
echo $summe | clip
echo "(re)buy $symbolParam $piecesParam $priceParam = $summe€ (in clipboard)"

if { [ -z "$priceFromOwnSymbolsFile" ]; } then
  # Newly added
  avgPrice=$(echo "$summe $piecesParam" | awk '{print $1 / $2}')
else
  # Exists in portfolio
  avgPrice=$(echo "$summe $totalAmountOfPieces" | awk '{print $1 / $2}')
fi

today=$(date --date="-0 day" +"%Y-%m-%d")
# shellcheck disable=SC2027,SC1003,SC2086
sed -i '1 i\'$symbolParam' '$avgPrice' '$today' '$totalAmountOfPieces' '$summe'€ '$SYMBOL_NAME'' "$OWN_SYMBOLS_FILE"

# Encript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null

echo ""

# Write buy/SYMBOL_DATE file
lastDateInDataFile=$(head -n1 data/"$symbolParam".txt | cut -f 1)
transactionSymbolLastDateFile="buy/""$symbolParam"_"$lastDateInDataFile".txt
commaListTransaction=$(cut -d ' ' -f 1-86 < "$transactionSymbolLastDateFile")
rm buy/"$symbolParam"_"$lastDateInDataFile".txt
echo "$commaListTransaction" "{x:1,y:$pricePlusFees,r:10}, " > buy/"$symbolParam"_"$lastDateInDataFile".txt

# Delete readable file
rm -rf "$OWN_SYMBOLS_FILE"

# Increment Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
count=$((count + 1))
rm -rf "$TRANSACTION_COUNT_FILE"
echo "$count" >> "$TRANSACTION_COUNT_FILE"
echo "Transactions: $count (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
