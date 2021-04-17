#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt
# and 
# Removing symbol from config/buying_rate.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh IBM

echo sell ${1} ...

sed -i "s/*${1} //" config/own_symbols.txt
sed -i "0,/^/s//${1} /" config/stock_symbols.txt

sed "/^${1} /d" config/buying_rate.txt > config/buying_rate_temp.txt
rm -rf config/buying_rate.txt
mv config_buying_rate_temp.txt config/buying_rate.txt

#git add config/own_symbols.txt config/stock_symbols.txt config/buying_rate.txt
#git commit -m "sell ${1}"
#git push
