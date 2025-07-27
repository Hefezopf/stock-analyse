#!/bin/bash

# This script checks to adds a symbol SA:
# Call: ./script/add-to-sa-check.sh SYMBOLS
# 1. Parameter: SYMBOLS - Stock symbols like: 'BEI DBK'
# Call example: ./script/add-to-sa-check.sh 'BEI DBK'
# Or alias atsac

# Import
# shellcheck disable=SC1091
. script/constants.sh

# Parameter
symbolsParameter=$(echo "$1" | tr '[:lower:]' '[:upper:]')

if { [ -z "$symbolsParameter" ]; } then
  echo "Not all parameters specified!"
  echo "Call: sh ./script/add-to-sa-check.sh SYMBOLS"
  echo "Example: sh ./script/add-to-sa-check.sh 'BEI DBK'"
  exit 1
fi

symbolsNotThere=""

for symbol in $symbolsParameter
do
    found=$(grep -n "$symbol" "$STOCK_SYMBOLS_FILE")
    if { [ "$found" ]; } then
        echo "Warning Symbol '"$symbol"' already there!"
    else
        echo "Not there:$symbol"
        symbolsNotThere="$symbolsNotThere $symbol"
    fi
done
echo "---------------"
echo "Summary symbolsNotThere:$symbolsNotThere"
