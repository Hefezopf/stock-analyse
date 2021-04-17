#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh IBM

echo sell ${1} ...

#sed -i "s/*${1} //" config/own_symbols.txt
sed -i "0,/^/s//${1} /" config/stock_symbols.txt

sed "/^${1} /d" config/own_symbols.txt > config/own_symbols_temp.txt
rm -rf config/own_symbols.txt
mv config/own_symbols_temp.txt config/own_symbols.txt

#git add config/own_symbols.txt config/stock_symbols.txt
#git commit -m "sell ${1}"
#git push
