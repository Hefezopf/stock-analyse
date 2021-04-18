#!/bin/sh

# Removing *symbol from config/own_symbols.txt
# and
# Adding symbol to config/stock_symbols.txt

# Call: sh ./sell.sh SYMBOL
# Example: sh ./sell.sh BEI
# alias sell='/d/code/stock-analyse/script/sell.sh $1'
# {"event_type": "sell", "client_payload": {"symbol": "BEI"}}

echo sell ${1} ...

if { [ -z "$1" ]; } then
  echo "Not all parameters specified!"
  echo "Example: curl_github_dispatch_sell.sh BEI"
  exit 1
fi

# Add in front of overall list
sed -i "0,/^/s//${1} /" config/stock_symbols.txt

# Remove from own list
sed -i "/^${1} /d" config/own_symbols.txt

#git add config/own_symbols.txt config/stock_symbols.txt
#git commit -m "sell ${1}"
#git push