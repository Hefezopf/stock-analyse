#!/bin/sh

# Alphabetic sorting of all Symbols in config/stock_symbols.txt
# Do manually every other month, to sort all available symbols again.
# Or scheduled with ../workflows/sort.workflow.yml

# Call: sh ./script/sort_sa.sh

set -x

echo "Sorting..."


cat config/stock_symbols.txt 
echo "Sorting...1"
cat config/stock_symbols.txt | tr " " "\n" | 
echo "Sorting...2"
cat config/stock_symbols.txt | tr " " "\n" | sort
echo "Sorting...3"
cat config/stock_symbols.txt | tr " " "\n" | sort | tr "\n" " "
echo "Sorting...4"

# Sort symbols in stock_symbols.txt
cat config/stock_symbols.txt | tr " " "\n" | sort | tr "\n" " " > config/stock_symbols_temp.txt




ls config/stock_symbols_temp.txt -lisa
cat config/stock_symbols_temp.txt


rm config/stock_symbols.txt
mv config/stock_symbols_temp.txt config/stock_symbols.txt

ls config/stock_symbols.txt -lisa
cat config/stock_symbols.txt
