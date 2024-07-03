#!/bin/bash

# https://github.com/bats-core/bats-core
# https://github.com/ztombol/bats-assert

# cd /D/code
# git clone https://github.com/bats-core/bats-core.git
# git clone https://github.com/bats-core/bats-assert.git
# cd bats-core
# ./install.sh ~
# 4 dirs are created in ~ (/c/Users/info/bin/bats)
# /libexec, /bin, /share and /lib
# bats -version

# To get rid of carage returns, may run:
# sed -i 's/\r//g' script/constants.sh
# sed -i 's/\r//g' simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh

# Call: . test.sh
# For time messurement use 'gnomon'
# npm install -g gnomon
# Call: . test.sh | gnomon --medium=1.0 --high=4.0 --ignore-blank --real-time=100

echo shellcheck ...
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

shellcheck --shell=bash script/averages.sh
shellcheck --shell=bash script/strategies.sh
shellcheck --shell=bash script/constants.sh
shellcheck --shell=bash script/functions.sh
shellcheck --shell=bash script/buy.sh
shellcheck --shell=bash script/sell.sh
shellcheck --shell=bash script/curl/curl_getInformerData.sh
shellcheck --shell=bash script/view_portfolio.sh
shellcheck --shell=bash script/marketcap-update.sh
shellcheck --shell=bash script/git_cleanup.sh
shellcheck --shell=bash script/sort_sa.sh
shellcheck --shell=bash simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh
shellcheck --shell=bash simulate.sh
shellcheck --shell=bash analyse.sh

rm -rf test/_result.html

# /C/Users/xcg4444/bin/bats --tap test/*.bats
echo bats ...
bats -version
bats --tap --timing test/strategies.bats
bats --tap --timing test/functions.bats
bats --tap --timing test/averages.bats

bats --tap --timing test/analyse.bats
bats --tap --timing test/simulate.bats
