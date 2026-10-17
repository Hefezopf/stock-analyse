#!/bin/bash

# Correcting values in own_symbols.txt
# Specify the value to be replaced in own_symbols.txt
#
# Call: . script/correct_values.sh SYMBOL PIECES BUY_IN_PRICE OVERALL_VALUE
# Example: source ./script/correct_values.sh BEI 100 9.99 100000
# alias cv='/d/code/stock-analyse/script/correct_values.sh $1 $2 $3 $4'
# Example: cv BEI 100 9.99 100000
# {"event_type": "correct", "client_payload": {"symbol": "BEI", "price": "9.99", "pieces": "100", "overall": "100000"}}

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

_symbolParam=$1
_piecesParam=$2
_buyInPriceParam=$3
_overallParam=$4

# To uppercase
symbolParam="${_symbolParam^^}" # all uppercase

# Pieces has to be without dot
piecesParam="${_piecesParam//\./}"

# Price has to be without comma -> replace comma with dot
buyInPriceParam="${_buyInPriceParam//,/.}"

# Pieces has to be without dot
overallParam="${_overallParam//\./}"

if { [ -z "$symbolParam" ] || [ -z "$piecesParam" ] || [ -z "$buyInPriceParam" ] || [ -z "$overallParam" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Call: sh ./correct_values.sh SYMBOL PIECES BUY_IN_PRICE OVERALL_VALUE"
  echo "Example: sh ./correct_values.sh BEI 100 9.99 100000"
  exit 1
fi

if { [ "${piecesParam:0:1}" = "-" ]; } then
    echo "Error: Pieces can not be negativ!"
    exit 2
fi

if [ "${symbolParam::1}" = '*' ]; then
    symbolParam="${symbolParam:1:7}"
fi

#sed -i 's/config/#config/g' .gitignore

# Decript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null

# Open Editor
#flatpak run com.vscodium.codium /media/markus/BigBerta/code/stock-analyse/"$OWN_SYMBOLS_FILE"

# Correct values
lineFromSymbolsFile=$(grep -m1 -P "^$symbolParam " "$OWN_SYMBOLS_FILE")
BUY_DATE=$(echo "$lineFromSymbolsFile" | cut -f 3 -d ' ')
SYMBOL_NAME=$(echo "$lineFromSymbolsFile" | cut -f 6 -d ' ')

# Remove symbol from own list
sed -i "/^$symbolParam /d" "$OWN_SYMBOLS_FILE"

# Add symbol on top of the own list
sed -i '1 i\'$symbolParam' '$buyInPriceParam' '$BUY_DATE' '$piecesParam' '$overallParam'€ '$SYMBOL_NAME'' "$OWN_SYMBOLS_FILE"

# Correct values
# read -r -n 1 -p "Correct values in 'config/own_symbols.txt' now and then hit ANY KEY! -> NOT ENTER, NOT SPACE" correctValuesInput
# # shellcheck disable=SC2154
# if [ -z "$correctValuesInput" ]; then
#     echo "exit"
#     exit 1
# fi

# Encript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null
# Delete readable file own_symbols.txt
rm -rf "$OWN_SYMBOLS_FILE"

#echo -e "\n"
#. /media/markus/BigBerta/code/stock-analyse/script/view_portfolio.sh


#git checkout .gitignore

#read -r -p "Press enter to commit (or CTRL+C to abort)"

#git commit -am "correct values" "$OWN_SYMBOLS_FILE".gpg
