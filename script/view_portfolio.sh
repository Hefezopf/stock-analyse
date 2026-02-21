#!/bin/bash

# Encrypt and view portfolio in config/own_symbols.txt
#
# Call: . view_portfolio.sh
# Example: . view_portfolio.sh
# alias vp='/d/code/stock-analyse/script/view_portfolio.sh'

# Import
# shellcheck disable=SC1091
. script/constants.sh

TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
TEMP_FILE2="$(mktemp -p "$TEMP_DIR")"

echo "View Portfolio ..."

if { [ -z "$GPG_PASSPHRASE" ] ; } then
  echo "Error: GPG_PASSPHRASE Not specified!"
  echo "Example: view_portfolio.sh"
  exit 1
fi

gpg --decrypt --pinentry-mode=loopback --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg > "$TEMP_FILE" 2>/dev/null

sed -i 's/ /\t/g' "$TEMP_FILE"


###################
# shellcheck disable=SC2013
for symbol in $(awk '{print $1}' "$TEMP_FILE")
do
    lineFromOwnSymbolsFile=$(grep -m1 -P "$symbol" "$TEMP_FILE")
    DATA_DATE_FILE="$DATA_DIR/$symbol.txt"
    lastQuote=$(head -n1 "$DATA_DATE_FILE" | awk '{print $2}')
    avgPrice=$(echo "$lineFromOwnSymbolsFile" | cut -f 2)
    today=$(echo "$lineFromOwnSymbolsFile" | cut -f 3)
    totalAmountOfPieces=$(echo "$lineFromOwnSymbolsFile" | cut -f 4)
    summe=$(echo "$lineFromOwnSymbolsFile" | cut -f 5)
    SYMBOL_NAME=$(echo "$lineFromOwnSymbolsFile" | cut -f 6)
    performance=$(echo "$avgPrice $lastQuote" | awk '{print (100 * $2 / $1) - 100}')
    performance=$(printf "%.1f" "$performance")

    avgPrice=$(printf "%.2f" "$avgPrice")
    # shellcheck disable=SC2001
    avgPrice=$(echo "$avgPrice" | sed 's/.00/.0/g')
    
    echo -e "$symbol\t$avgPrice€\t$today\t$totalAmountOfPieces\t$summe\t$performance%\t$SYMBOL_NAME" >> "$TEMP_FILE2"
    echo -n .
done
mv "$TEMP_FILE2" "$TEMP_FILE"
echo ""
###################

echo ""

echo -e "Symbol\tBuyIn\tDate\t\tPieces\tSum\tPerfor.\tName"
if [ "$1" ]; then
    sort -k6 -n "$TEMP_FILE"
else
    cat "$TEMP_FILE"
fi

echo ""

overallPositions=$(awk 'END { print NR }' "$TEMP_FILE")
echo "Overall Positions: $overallPositions"

rm -rf "$TEMP_FILE"
rm -rf "$TEMP_FILE2"

#echo ""

# Read and output Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
echo "Transaction count: $count (Year $(date +%Y))"
