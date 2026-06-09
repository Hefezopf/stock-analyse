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

echo -e "Date\t\tWin\tPercent\tSymbol\t\tName"

lineFromFile="${lineFromFile//<div>/}"
lineFromFile="${lineFromFile//&nbsp;/ }"
lineFromFile="${lineFromFile//<\/a><\/div>/}"
lineFromFile="${lineFromFile//\/\/htmlpreview/}"
lineFromFile="${lineFromFile//target=/}"
lineFromFile="${lineFromFile//_blank/}"
lineFromFile="${lineFromFile//https/}"
lineFromFile="${lineFromFile//github/}"
lineFromFile="${lineFromFile//Hefezopf\/stock-analyse/}"
lineFromFile="${lineFromFile//\/blob\/main\/out/}"
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t/ /g')
lineFromFile="${lineFromFile//a href=/}"
lineFromFile="${lineFromFile//&#8364;/€}"
lineFromFile="${lineFromFile//</}"
lineFromFile="${lineFromFile//>/}"
lineFromFile="${lineFromFile//\.html/}"
lineFromFile="${lineFromFile//\.com/}"
lineFromFile="${lineFromFile//\.io/}"
lineFromFile="${lineFromFile//:.\/?:\/\/\/\//}"
lineFromFile="${lineFromFile//\'/}"

if [ "$symbolParam" ]; then
    lineFromFile=${lineFromFile/$symbolParam $symbolParam/$symbolParam}
#else
#    echo ""
fi

# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/ /\t/g')
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t\t/\t/g')
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t\t/\t/g')
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t2026-/2026-/g')
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t2027-/2027-/g')
# shellcheck disable=SC2001
lineFromFile=$(echo "$lineFromFile" | sed 's/\t2028-/2028-/g')
#year=$(date +%Y)
#echo "YEAR $year"
#cat "$STOCK_SYMBOLS_FILE" | sed -i s/"$symbolParam "// "$STOCK_SYMBOLS_FILE"
#lineFromFile=$(echo "$lineFromFile" | sed -i s/\t"$year"-/"$year"-/g)


echo "$lineFromFile"
echo ""
echo "Sum before tax: $summe€"

count=$(cat "$TRANSACTION_COUNT_FILE")
echo "Transaction count: $count (Year $(date +%Y))"
