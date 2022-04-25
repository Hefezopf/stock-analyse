#!/bin/sh

# Alphabetic sorting of all Symbols in config/stock_symbols.txt
# Do manually every other month, to sort all available symbols again.
# Or scheduled with ../workflows/sort.workflow.yml

# Call: sh ./script/sort_sa.sh

#set -x

# Import
# shellcheck disable=SC1091
. ./script/constants.sh

echo "Sorting..."

# Sort symbols in stock_symbols.txt
symbolListe=$(cat "$STOCK_SYMBOLS_FILE")
symbolListe=$(echo "$symbolListe" | tr " " "\n" | sort | tr "\n" " ")

# TODO delete first blank in done, if exists
symbolListe="${symbolListe:1}"

TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
echo "$symbolListe" >> "$TEMP_FILE"
rm "$STOCK_SYMBOLS_FILE"
mv "$TEMP_FILE" "$STOCK_SYMBOLS_FILE"
