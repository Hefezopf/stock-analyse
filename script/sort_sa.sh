#!/bin/sh

# Alphabetic sorting of all Symbols in config/stock_symbols.txt
# Do manually every other month, to sort all available symbols again.
# Or scheduled with ..\workflows\sort.workflow.yml

# Call: sh ./sort_sa.sh

#set -x

echo "Sorting..."

# Sort symbols in stock_symbols.txt
cat config/stock_symbols.txt | tr " " "\n" | sort | tr "\n" " " > config/stock_symbols.txt
