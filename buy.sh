#!/bin/sh

# Adding *symbol to config/own_symbols.txt
# and
# Removing symbol from config/stock_symbols.txt
# and
# Adding symbol to config/buying_rate.txt

# Call: sh ./buy.sh SYMBOL BUYING_RATE
# Example: sh ./buy.sh IBM 9.99

echo buy ${1} ${2} ...

#sed -i "0,/^/s//*${1} /" config/own_symbols.txt
sed -i "s/${1} //" config/stock_symbols.txt

sed -i '1 i\'${1}' '${2}'' config/buying_rate.txt

# git add config/own_symbols.txt config/stock_symbols.txt config/buying_rate.txt
# git commit -m "buy ${1} ${2}"
# git push