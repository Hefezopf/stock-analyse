#!/bin/sh

# Encrypt and view portfolio in config/own_symbols.txt

# Call: sh ./view_own_symbols.sh
# Example: sh ./view_own_symbols.sh
# alias vp='/d/code/stock-analyse/script/view_own_symbols.sh'

echo "view portfolio ..."

if { [ -z "$GPG_PASSPHRASE" ] ; } then
  echo "GPG_PASSPHRASE Not specified!"
  echo "Example: view_own_symbols.sh"
  exit 1
fi

gpg --decrypt --pinentry-mode=loopback --batch --yes --passphrase $GPG_PASSPHRASE config/own_symbols.txt.gpg