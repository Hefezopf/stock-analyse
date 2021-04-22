#!/bin/sh

# Adding *symbol to config/own_symbols.txt
# and
# Removing symbol from config/stock_symbols.txt
# Covers rebuy scenario as well!

# Call: sh ./buy.sh SYMBOL PRICE PIECES
# Example: sh ./buy.sh BEI 9.99 100
# alias buy='/d/code/stock-analyse/script/buy.sh $1 $2 $3'
# {"event_type": "buy", "client_payload": {"symbol": "BEI", "price": "9.99", "pieces": "100"}}

# To uppercase
symbolParam=$(echo "${1}" | tr '[:lower:]' '[:upper:]')

echo "(re)buy ${symbolParam} ${2} ${3} ..."

if { [ -z "$symbolParam" ] || [ -z "$2" ] || [ -z "$3" ]; } then
  echo "Not all parameters specified!"
  echo "Call: sh ./buy.sh SYMBOL PRICE PIECES"
  echo "Example: sh ./buy.sh BEI 9.99 100"
  exit 1
fi

case "$symbolParam" in
    ''|*[!A-Z]*) echo "Error: SYMBOL Not a valid alpha numeric!" >&2; exit 2 ;;
esac

case "$3" in
    ''|*[!0-9]*) echo "Error: PIECES Not a integer number!" >&2; exit 2 ;;
esac

# Remove from overall list, if not there do nothing
sed -i "s/${symbolParam} //" config/stock_symbols.txt

# Decript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" config/own_symbols.txt.gpg 2>/dev/null

# Rebuy: Remove from own list, if not there do nothing
sed -i "/^${symbolParam} /d" config/own_symbols.txt

# Add in front of own list
today=$(date --date="-0 day" +"%Y-%m-%d")
sed -i '1 i\'${symbolParam}' '${2}' '$today' '${3}'' config/own_symbols.txt

# Encript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c config/own_symbols.txt 2>/dev/null

# Delete readable file
rm -rf config/own_symbols.txt

echo ""

# Increment TX
count=$(cat config/transaction_count.txt)
count=$((count + 1))
rm -rf config/transaction_count.txt
echo "Transactions: "$count" (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
echo "$count" >> config/transaction_count.txt