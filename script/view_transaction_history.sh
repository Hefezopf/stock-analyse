#!/bin/bash

# View transaction history from file config/transaction_history.txt
#
# Call: . script/view_transaction_history.sh SYMBOL | DATE | Searchstring
# Example: . script/view_transaction_history.sh BEI
# Example: . script/view_transaction_history.sh 2022-03-
# Example: . script/view_transaction_history.sh 2022
# Example: . script/view_transaction_history.sh Lululemon
# alias vt='/d/code/stock-analyse/script/view_transaction_history.sh $1'

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

# To uppercase
#symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
symbolParam=$1

echo "View Transaction History $symbolParam"
echo ""

lineFromFile=$(grep -F "$symbolParam" "$TRANSACTION_HISTORY_FILE")
#<div style='font-size: x-large;'>&nbsp;2025-10-03&#9;133&#8364;&#9;4.9%&#9;<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/58H.html' target='_blank'>58H&#9;"Davide-Campari"</a></div><br>
echo "$lineFromFile"

lineFromFile=$(echo "$lineFromFile" | sed 's/&#9;/\t/g')

#\t245&#8364;
priceFromFile=$(echo "$lineFromFile" | cut -f 2)

priceFromFile=$(echo "$priceFromFile" | sed 's/%//g')
priceFromFile=$(echo "$priceFromFile" | sed 's/&#9;/\t/g')
  
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')

echo ""
echo "Sum before tax: $summe€"
