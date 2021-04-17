#!/bin/sh

# Adding *symbol to config/own_symbols.txt
# and
# Removing symbol from config/stock_symbols.txt

# Call: sh ./buy.sh SYMBOL BUYING_RATE
# Example: sh ./buy.sh IBM 9.99
# alias buy='/d/code/stock-analyse/script/buy.sh $1 $2'

echo buy ${1} ${2} ...

sed -i "s/${1} //" config/stock_symbols.txt
sed -i '1 i\'${1}' '${2}'' config/own_symbols.txt

# git add config/own_symbols.txt config/stock_symbols.txt
# git commit -m "buy ${1} ${2}"
# git push