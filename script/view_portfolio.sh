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