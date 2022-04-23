#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt

# Call: sh ./script/sell.sh SYMBOL
# Example: sh ./script/sell.sh BEI
# alias sell='/d/code/stock-analyse/script/sell.sh $1'
# {"event_type": "sell", "client_payload": {"symbol": "BEI"}}

TRANSACTION_COUNT_FILE=config/transaction_count.txt
OWN_SYMBOLS_FILE=config/own_symbols.txt
STOCK_SYMBOLS_FILE=config/stock_symbols.txt

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "Sell $symbolParam"

if { [ -z "$symbolParam" ]; } then
    echo "Not all parameters specified!"
    echo "Example: curl_github_dispatch_sell.sh BEI"
    exit 1
fi

# Add symbol in front of overall list
sed -i "0,/^/s//$symbolParam /" $STOCK_SYMBOLS_FILE

# Encrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" $OWN_SYMBOLS_FILE.gpg 2>/dev/null

# Remove symbol from own list
sed -i "/^$symbolParam /d" $OWN_SYMBOLS_FILE

# Decrypt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c $OWN_SYMBOLS_FILE 2>/dev/null

# Delete readable file
rm -rf $OWN_SYMBOLS_FILE
echo ""

# Increment TX
count=$(cat $TRANSACTION_COUNT_FILE)
count=$((count + 1))
rm -rf $TRANSACTION_COUNT_FILE
echo "Transactions: "$count" (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
echo "$count" >> $TRANSACTION_COUNT_FILE

# Write sell/SYMBOL_DATE file
lastDateInDataFile=$(head -n1 data/"$symbolParam".txt | cut -f 1)
lastPriceInDataFile=$(head -n1 data/"$symbolParam".txt | cut -f 2)
transactionSymbolLastDateFile="sell/""$symbolParam"_"$lastDateInDataFile".txt
commaListTransaction=$(cut -d ' ' -f 1-86 < "$transactionSymbolLastDateFile")
rm sell/"$symbolParam"_"$lastDateInDataFile".txt
echo "$commaListTransaction" "{x:1,y:"$lastPriceInDataFile",r:10}, " > sell/"$symbolParam"_"$lastDateInDataFile".txt


#echo ""

#chmod +x ./script/view_portfolio.sh
#./script/view_portfolio.sh
