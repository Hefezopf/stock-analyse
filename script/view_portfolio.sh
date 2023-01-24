#!/bin/sh

# Encrypt and view portfolio in config/own_symbols.txt
#
# Call: sh ./view_portfolio.sh
# Example: sh ./view_portfolio.sh
# alias vp='/d/code/stock-analyse/script/view_portfolio.sh'

# Import
# shellcheck disable=SC1091
. ./script/constants.sh

TEMP_FILE="$(mktemp -p "$TEMP_DIR")"

echo "View Portfolio ..."

if { [ -z "$GPG_PASSPHRASE" ] ; } then
  echo "GPG_PASSPHRASE Not specified!"
  echo "Example: view_portfolio.sh"
  exit 1
fi

gpg --decrypt --pinentry-mode=loopback --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg > "$TEMP_FILE"

echo ""

sed 's/ /\t/g' "$TEMP_FILE"

rm -rf "$TEMP_FILE"

echo ""

# Read and output Tx
count=$(cat "$TRANSACTION_COUNT_FILE")
echo "Transactions: $count (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."
