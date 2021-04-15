#!/bin/sh

# Removing *symbol from _own_symbols.txt
# and
# Adding symbol to _stock_symbols.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh IBM

echo sell ${1} ...

sed -i "s/*${1} //" data/_own_symbols.txt
sed -i "0,/^/s//${1} /" data/_stock_symbols.txt
git add data/_own_symbols.txt data/_stock_symbols.txt
git commit -m "sell ${1}"
git push
