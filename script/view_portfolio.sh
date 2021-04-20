#!/bin/sh

# Encrypt and view portfolio in config/own_symbols.txt

# Call: sh ./view_portfolio.sh
# Example: sh ./view_portfolio.sh
# alias vp='/d/code/stock-analyse/script/view_portfolio.sh'

echo "view portfolio ..."

if { [ -z "$GPG_PASSPHRASE" ] ; } then
  echo "GPG_PASSPHRASE Not specified!"
  echo "Example: view_portfolio.sh"
  exit 1
fi

gpg --decrypt --pinentry-mode=loopback --batch --yes --passphrase $GPG_PASSPHRASE config/own_symbols.txt.gpg

# Read TX
echo ""
echo ""
count=$(cat config/transaction_count.txt)
echo "Transactions: "$count" (150/250)"
echo "Quali Phase: 01.04. bis 30.09. and"
echo "Quali Phase: 01.10. bis 31.03."