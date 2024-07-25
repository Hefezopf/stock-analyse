#!/bin/bash

# View transaction history from file config/transaction_history.txt
#
# Call: . script/view_transaction_history.sh SYMBOL | DATE
# Example: . script/view_transaction_history.sh BEI
# Example: . script/view_transaction_history.sh 2022-03-
# Example: . script/view_transaction_history.sh 2022
# alias vt='/d/code/stock-analyse/script/view_transaction_history.sh $1'

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "View Transaction History $symbolParam"

lineFromFile=$(grep -F "$symbolParam" "$TRANSACTION_HISTORY_FILE")
# BEI	2022-04-23	352	SELL	"BEIERSDORF"
priceFromFile=$(echo "$lineFromFile" | cut -f 3)
#echo "$priceFromFile€"
echo "$lineFromFile"

summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')

echo "Sum before tax: $summe€"
