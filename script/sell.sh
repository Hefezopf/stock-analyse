#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt

# Call: sh ./script/sell.sh SYMBOL
# Example: sh ./script/sell.sh BEI
# alias sell='/d/code/stock-analyse/script/sell.sh $1'
# {"event_type": "sell", "client_payload": {"symbol": "BEI"}}

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "Sell $symbolParam"

if { [ -z "$symbolParam" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_sell.sh BEI"
  exit 1
fi

# Remove from overall list, if not there do nothing
#sed -i "s/${symbolParam} //" config/stock_symbols.txt

# Add in front of overall list
sed -i "0,/^/s//$symbolParam /" config/stock_symbols.txt

# Encrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" config/own_symbols.txt.gpg 2>/dev/null

# Remove from own list
sed -i "/^$symbolParam /d" config/own_symbols.txt

# Decrypt
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

# Write sell/SYMBOL_DATE file

# Check, if quote day is from last trading day, including weekend
yesterday=$(date --date="-1 day" +"%Y-%m-%d")
dayOfWeek=$(date +%u)
if [ "$dayOfWeek" -eq 7 ]; then # 7 SUN
    yesterday=$(date --date="-2 day" +"%Y-%m-%d")
fi
if [ "$dayOfWeek" -eq 1 ]; then # 1 MON
    yesterday=$(date --date="-3 day" +"%Y-%m-%d")
fi
transactionSymbolLastDateFile="sell/""$symbolParam"_"$yesterday".txt
commaListTransaction=$(cut -d , -f 2-90 < "$transactionSymbolLastDateFile")
echo "$commaListTransaction""{x: 1, y: 10, r: 10}," > sell/"$symbolParam"_"$today".txt
#rm sell/"$symbolParam"_"$yesterday".txt