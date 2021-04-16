#!/bin/sh

# Removing *symbol from data/_own_symbols.txt
# and
# Adding symbol to data/_stock_symbols.txt
# and 
# Removing symbol from data/_buying_rate.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh IBM

echo sell ${1} ...

sed -i "s/*${1} //" data/_own_symbols.txt
sed -i "0,/^/s//${1} /" data/_stock_symbols.txt

sed "/^${1} /d" data/_buying_rate.txt > data/_buying_rate_temp.txt
rm -rf data/_buying_rate.txt
mv data/_buying_rate_temp.txt data/_buying_rate.txt

#git add data/_own_symbols.txt data/_stock_symbols.txt data/_buying_rate.txt
#git commit -m "sell ${1}"
#git push
