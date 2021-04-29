#!/bin/sh

# https://github.com/bats-core/bats-core
# https://github.com/ztombol/bats-assert

# git clone https://github.com/bats-core/bats-core.git
# git clone https://github.com/bats-core/bats-assert.git
# cd bats-core
# ./install.sh ~
# 4 dirs are created in ~ 
# libexec, bin share and lib
# bats -version

# To get rid of carage returns, may run: sed -i 's/\r//g' script/constants.sh

echo shellcheck ...
cat simulate/simulate-buyRSILowDivergent-sellHighStoch.sh | tr -d '\r' > simulate/simulate-buyRSILowDivergent-sellHighStoch1.sh
rm simulate/simulate-buyRSILowDivergent-sellHighStoch.sh
mv simulate/simulate-buyRSILowDivergent-sellHighStoch1.sh simulate/simulate-buyRSILowDivergent-sellHighStoch.sh

cat simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh | tr -d '\r' > simulate/simulate-buyRSILowMACDNegativ-sellHighStoch1.sh
rm simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh
mv simulate/simulate-buyRSILowMACDNegativ-sellHighStoch1.sh simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh

cat script/constants.sh | tr -d '\r' > script/constants1.sh
rm script/constants.sh
mv script/constants1.sh script/constants.sh

cat script/functions.sh | tr -d '\r' > script/functions1.sh
rm script/functions.sh
mv script/functions1.sh script/functions.sh

cat script/strategies.sh | tr -d '\r' > script/strategies1.sh
rm script/strategies.sh
mv script/strategies1.sh script/strategies.sh

cat analyse.sh | tr -d '\r' > analyse1.sh
rm analyse.sh
mv analyse1.sh analyse.sh

shellcheck --shell=bash simulate/simulate-buyRSILowDivergent-sellHighStoch.sh
shellcheck --shell=bash simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh
shellcheck --shell=bash script/constants.sh
shellcheck --shell=bash script/functions.sh
shellcheck --shell=bash script/strategies.sh
shellcheck --shell=bash analyse.sh

rm -rf test/_result.html

# /C/Users/xcg4444/bin/bats --tap script/*.bats
echo bats ...
bats --tap script/averages.bats
bats --tap script/strategies.bats
bats --tap script/functions.bats
