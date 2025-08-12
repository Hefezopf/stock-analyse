#!/bin/bash

# Delete all files for a $Symbol from Stock Analyse
# Delete $SYMBOL in stock_symbols.txt
# Delete File $SYMBOL.html in /out
# Delete Files $SYMBOL*.txt in /alarm, /buy, /data, /history, /sell
#
# Call: . script/delete_from_sa.sh SYMBOL
# Example: . script/delete_from_sa.sh BEI
# alias dfsa='/d/code/stock-analyse/script/delete_from_sa.sh $1'

# Import
# shellcheck disable=SC1091
. script/constants.sh

# To uppercase
symbolParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "Delete all files for $symbolParam"

if { [ -z "$symbolParam" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Example: delete_from_sa.sh BEI"
  exit 1
fi

# Delete $SYMBOL in stock_symbols.txt
# shellcheck disable=SC2002
cat "$STOCK_SYMBOLS_FILE" | sed -i s/"$symbolParam "// "$STOCK_SYMBOLS_FILE"

sed -i "/$symbolParam\t/d" "$TICKER_NAME_ID_FILE"

sed -i "/\/$symbolParam/d" "$SCRIPT_START_ALL_IN_CHROME_FILE"

# Delete all files
rm -rf out/"$symbolParam".html
rm -rf alarm/"$symbolParam"*.txt
rm -rf buy/"$symbolParam"*.txt
rm -rf "$DATA_DIR/$symbolParam"*.txt
rm -rf history/"$symbolParam"*.txt
rm -rf sell/"$symbolParam"*.txt
rm -rf status/"$symbolParam"*.txt
rm -rf simulate/out/"$symbolParam"*.html
