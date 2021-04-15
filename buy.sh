#!/bin/sh

# Adding *symbol to _own_symbols.txt
# and
# Removing symbol from _stock_symbols.txt

# Call: sh ./buy.sh SYMBOL
# Example: sh ./buy.sh IBM

echo buy ${1} ...

sed -i "0,/^/s//*${1} /" data/_own_symbols.txt
sed -i "s/${1} //" data/_stock_symbols.txt
git add data/_own_symbols.txt data/_stock_symbols.txt
git commit -m "buy ${1}"
git push