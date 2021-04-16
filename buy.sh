#!/bin/sh

# Adding *symbol to data/_own_symbols.txt
# and
# Removing symbol from data/_stock_symbols.txt
# and
# Adding symbol to data/_buying_rate.txt

# Call: sh ./buy.sh SYMBOL BUYING_RATE
# Example: sh ./buy.sh IBM 9.99

echo buy ${1} ${2} ...

sed -i "0,/^/s//*${1} /" data/_own_symbols.txt
sed -i "s/${1} //" data/_stock_symbols.txt

sed -i '1 i\'${1}' '${2}'' data/_buying_rate.txt

# git add data/_own_symbols.txt data/_stock_symbols.txt data/_buying_rate.txt
# git commit -m "buy ${1} ${2}"
# git push