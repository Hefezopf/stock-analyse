#!/bin/sh

# Adding *symbol to config/own_symbols.txt
# and
# Removing symbol from config/stock_symbols.txt
# Covers rebuy scenario as well!

# Call: sh ./buy.sh SYMBOL BUYING_RATE
# Example: sh ./buy.sh BEI 9.99
# alias buy='/d/code/stock-analyse/script/buy.sh $1 $2'
# {"event_type": "buy", "client_payload": {"symbol": "BEI", "avg": "9.99"}}

echo (re)buy ${1} ${2} ...

if { [ -z "$1" ] || [ -z "$2" ]; } then
  echo "Not all parameters specified!"
  echo "Example: buy.sh BEI 9.99"
  exit 1
fi

# Remove from overall list
sed -i "s/${1} //" config/stock_symbols.txt

# Rebuy: Remove from own list, if not there do nothing
sed -i "/^${1} /d" config/own_symbols.txt

# Add in front of own list
sed -i '1 i\'${1}' '${2}'' config/own_symbols.txt

# git add config/own_symbols.txt config/stock_symbols.txt
# git commit -m "buy ${1} ${2}"
# git push