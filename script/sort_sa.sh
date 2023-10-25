#!/bin/bash

# Alphabetic sorting of all Symbols in config/stock_symbols.txt
# Do manually every other week, to sort all available symbols again.
# Or scheduled with ../workflows/sort.workflow.yml

# Call: script/sort_sa.sh

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

echo "Sorting..."

# Sort symbols in stock_symbols.txt
symbolListe=$(cat "$STOCK_SYMBOLS_FILE")
symbolListe=$(echo "$symbolListe" | tr " " "\n" | sort | tr "\n" " ")

# Delete first blank char, if exists
firstChar="$(printf '%s' "$symbolListe" | cut -c1)"
if [ "$firstChar" = ' ' ]; then
  symbolListe="$(printf '%s' "$symbolListe" | cut -c 2-)"
fi

TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
echo "$symbolListe" >> "$TEMP_FILE"
rm "$STOCK_SYMBOLS_FILE"
mv "$TEMP_FILE" "$STOCK_SYMBOLS_FILE"


# Sort INDEX (Fonds) at the end
only_indexes_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
other_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
for symbol in $symbolListe
do
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    asset_type=$(echo "$lineFromTickerFile" | cut -f 10)
    echo -n .
    if [ "$asset_type" = 'INDEX' ]; then
        echo -e "$symbol" >> "$only_indexes_TEMP_FILE"
    else
        echo -e "$symbol" >> "$other_TEMP_FILE"
    fi
done

only_indexes_line_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
only_other_line_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
awk '$1=$1' ORS=' ' "$only_indexes_TEMP_FILE" > "$only_indexes_line_TEMP_FILE"
awk '$1=$1' ORS=' ' "$other_TEMP_FILE" > "$only_other_line_TEMP_FILE"
new_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
cat "$only_other_line_TEMP_FILE" > "$new_TEMP_FILE"
cat "$only_indexes_line_TEMP_FILE" >> "$new_TEMP_FILE"
echo >> "$new_TEMP_FILE"
mv "$new_TEMP_FILE" "$STOCK_SYMBOLS_FILE"

rm "$only_indexes_TEMP_FILE"
rm "$other_TEMP_FILE"
rm "$only_indexes_line_TEMP_FILE"
rm "$only_other_line_TEMP_FILE"
