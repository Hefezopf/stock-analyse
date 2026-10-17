#!/bin/bash

# Correcting values in own_symbols.txt
#
# Call: . script/correct_values.sh
# Example: source ./script/correct_values.sh 
# alias cv='/d/code/stock-analyse/script/correct_values.sh'

#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh

sed -i 's/config/#config/g' .gitignore

# Decript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null
flatpak run com.vscodium.codium /media/markus/BigBerta/code/stock-analyse/"$OWN_SYMBOLS_FILE"
read -n 1 -p "Correct values in 'config/own_symbols.txt' now and then hit ANY KEY! -> NOT ENTER, NOT SPACE" correctValuesInput

# Encript
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" -c "$OWN_SYMBOLS_FILE" 2>/dev/null
# Delete readable file own_symbols.txt
rm -rf "$OWN_SYMBOLS_FILE"

. /media/markus/BigBerta/code/stock-analyse/script/view_portfolio.sh

git checkout .gitignore

read -p "Press enter to commit (or CTRL+C to abort)"

#git commit -am "correct values" "$OWN_SYMBOLS_FILE".gpg
