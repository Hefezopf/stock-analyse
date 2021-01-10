#!/bin/sh

# https://github.com/bats-core/bats-core
# https://github.com/ztombol/bats-assert

# git clone https://github.com/bats-core/bats-core.git
# git clone https://github.com/bats-core/bats-assert.git
# cd bats-core
# ./install.sh ~
# Es werden 4 dirs in ~ angelegt 
# libexec, bin share und lib
# bats -version

echo shellcheck ...
cat script/functions.sh | tr -d '\r' > script/functions1.sh
rm script/functions.sh
mv script/functions1.sh script/functions.sh

cat script/strategies.sh | tr -d '\r' > script/strategies1.sh
rm script/strategies.sh
mv script/strategies1.sh script/strategies.sh

cat analyse.sh | tr -d '\r' > analyse1.sh
rm analyse.sh
mv analyse1.sh analyse.sh

shellcheck --shell=bash script/functions.sh
shellcheck --shell=bash script/strategies.sh
shellcheck --shell=bash analyse.sh

rm -rf test/_result.html

# /C/Users/xcg4444/bin/bats --tap script/*.bats
echo bats ...
bats --tap script/strategies.bats
bats --tap script/functions.bats
