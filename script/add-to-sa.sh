#!/bin/bash

# This script adds a symbol to various files. Steps:
# 1. run analyse.sh
# 2. add to config: stock_symbols.txt
# 3. add to start-all-in-chrome.sh
# 4. manuallay add edit ticker_name_id.txt (Correct Names and paste notation-Id)
#    press key to continue
# 5. run script/curl/curl_getInformerData.sh
# 6. run script/marketcap-update.sh
# Call: ./script/add-to-sa.sh SYMBOL
# 1. Parameter: SYMBOL - A stock symbols like: 'BEI'
# Call example: ./script/add-to-sa.sh 'BEI'
# Or alias atsa

# Import
# shellcheck disable=SC1091
. script/constants.sh

# Parameter
symbolsParameter=$(echo "$1" | tr '[:lower:]' '[:upper:]')

if { [ -z "$symbolsParameter" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Call: sh ./script/add-to-sa.sh SYMBOL"
  echo "Example: sh ./script/add-to-sa.sh 'BEI'"
  exit 1
fi

found=$(grep -n "$symbolsParameter" "$STOCK_SYMBOLS_FILE")
if { [ "$found" ]; } then
  echo "Error: Symbol $symbolsParameter already there!"
  exit 2
fi

if [ "$symbolsParameter" = 'CON' ]; then
  echo "Error: Symbol $symbolsParameter causes UNIX problems !!!DO NOT ADD!!!"
  exit 3
fi

# 1.
. analyse.sh "$symbolsParameter" 2 9 25 cc
rm -rf "$OUT_RESULT_FILE"

# 2.
sed -i -z 's/^\n*\|\n*$//g' "$STOCK_SYMBOLS_FILE"
echo -n "$symbolsParameter " >> "$STOCK_SYMBOLS_FILE"
echo "" >> "$STOCK_SYMBOLS_FILE"

# 3.
echo "start chrome https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbolsParameter.html" >> "$SCRIPT_START_ALL_IN_CHROME_FILE"

# 4.
read -r -n 1 -p "Correct values in 'config/ticker_name_id.txt' (Name + ID_NOTATION) now and then hit ->ANY key!"

# 5.
. script/curl/curl_getInformerData.sh "$symbolsParameter"

# 6.
. script/marketcap-update.sh "$symbolsParameter"
