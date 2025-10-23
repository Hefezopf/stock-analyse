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

# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/&#9;/\t/g')

#\t245&#8364;
priceFromFile=$(echo "$lineFromFile" | cut -f 2)

# shellcheck disable=SC2001
priceFromFile=$(echo "$priceFromFile" | sed 's/%//g')
# shellcheck disable=SC2001
priceFromFile=$(echo "$priceFromFile" | sed 's/&#9;/\t/g')
  
summe=$(echo "$priceFromFile" | awk '{s += $1;} END {print s;}')

lineFromFile=$(echo "$lineFromFile" | sed 's/<div>//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/&nbsp;/ /g')
lineFromFile=$(echo "$lineFromFile" | sed 's/<\/a><\/div>//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\/\/htmlpreview//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/target=//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/_blank//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/https//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/github//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/Hefezopf\/stock-analyse//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\/blob\/main\/out//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\t/ /g')
lineFromFile=$(echo "$lineFromFile" | sed 's/a href=//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/&#8364;/€/g')
lineFromFile=$(echo "$lineFromFile" | sed 's/<//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/>//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\.html//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\.com//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/\.io//g')
lineFromFile=$(echo "$lineFromFile" | sed 's/:.\/?:\/\/\/\///g')
lineFromFile=$(echo "$lineFromFile" | sed "s/'//g")

echo "$lineFromFile"
echo ""
echo "Sum before tax: $summe€"
