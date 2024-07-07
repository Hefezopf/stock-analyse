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


# Sort STOCK, COIN, INDEX (Fonds) at the end
stocks_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
coin_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
index_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
for symbol in $symbolListe
do
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    echo -n .
    if [ "$asset_type" = 'STOCK' ]; then
        echo -e "$symbol" >> "$stocks_TEMP_FILE"
    else
        if [ "$asset_type" = 'COIN' ]; then
            echo -e "$symbol" >> "$coin_TEMP_FILE"
        else
            if [ "$asset_type" = 'INDEX' ]; then
                echo -e "$symbol" >> "$index_TEMP_FILE"
            else
                echo "ERROR!!!!!!!!!!!!!: " "$symbol" "$asset_type"
            fi
        fi

    fi
done

stocks_line_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
awk '$1=$1' ORS=' ' "$stocks_TEMP_FILE" > "$stocks_line_TEMP_FILE"
coin_line_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
awk '$1=$1' ORS=' ' "$coin_TEMP_FILE" > "$coin_line_TEMP_FILE"
index_line_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
awk '$1=$1' ORS=' ' "$index_TEMP_FILE" > "$index_line_TEMP_FILE"
new_TEMP_FILE="$(mktemp -p "$TEMP_DIR")"
cat "$stocks_line_TEMP_FILE" > "$new_TEMP_FILE"
# TODO FIX
# shellcheck disable=SC2129
cat "$coin_line_TEMP_FILE" >> "$new_TEMP_FILE"
cat "$index_line_TEMP_FILE" >> "$new_TEMP_FILE"
echo >> "$new_TEMP_FILE"
mv "$new_TEMP_FILE" "$STOCK_SYMBOLS_FILE"

rm "$stocks_TEMP_FILE"
rm "$coin_TEMP_FILE"
rm "$index_TEMP_FILE"
rm "$stocks_line_TEMP_FILE"
rm "$coin_line_TEMP_FILE"
rm "$index_line_TEMP_FILE"

