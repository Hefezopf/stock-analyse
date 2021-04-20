#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh BEI
# alias sell='/d/code/stock-analyse/script/sell.sh $1'
# {"event_type": "sell", "client_payload": {"symbol": "BEI"}}

echo "sell ${1} ..."

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_sell.sh BEI"
  exit 1
fi

# Add in front of overall list
sed -i "0,/^/s//${1} /" config/stock_symbols.txt

# Encrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" config/own_symbols.txt.gpg 2>/dev/null

# Remove from own list
sed -i "/^${1} /d" config/own_symbols.txt

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c config/own_symbols.txt 2>/dev/null

# Delete readable file
rm -rf config/own_symbols.txt

# Increment TX
count=$(cat config/transaction_count.txt)
count=$((count + 1))
rm -rf config/transaction_count.txt
echo "$count" >> config/transaction_count.txt
echo "Transactions: "$count" (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
