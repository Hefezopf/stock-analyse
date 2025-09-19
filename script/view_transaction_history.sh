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
# &nbsp;2025-09-19	<span>245&euro;</span>	4.8%	<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/RCF.html' target='_blank'>RCF	"Teleperformance"</a><br>

echo "$lineFromFile"

#<span>245&euro;</span>
priceFromFile=$(echo "$lineFromFile" | cut -f 2)

priceFromFile=$(echo "$priceFromFile" | sed 's/%//g')
priceFromFile=$(echo "$priceFromFile" | sed 's/<span>//g')
  
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')

echo ""
echo "Sum before tax: $summe€"
