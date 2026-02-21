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
# bats --version

# To get rid of carage returns, may run:
# sed -i 's/\r//g' script/constants.sh
# sed -i 's/\r//g' simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh

# Call: . test.sh
# For time messurement use 'gnomon'
# npm install -g gnomon
# Call: . test.sh | gnomon --medium=1.0 --high=4.0 --ignore-blank --real-time=100

START_TIME_MEASUREMENT=$(date +%s);

echo shellcheck ...

for filename in *.sh; do
   # shellcheck disable=SC2002
   cat "$filename" | tr -d '\r' > "$filename""1"
   rm "$filename"
   mv "$filename""1" "$filename"
done
for filename in *.sh; do
    shellcheck --shell=bash "$filename"
done

for filename in script/*.sh; do
   # shellcheck disable=SC2002
   cat "$filename" | tr -d '\r' > "$filename""1"
   rm "$filename"
   mv "$filename""1" "$filename"
   chmod +x "$filename"
done
for filename in script/*.sh; do
    shellcheck --shell=bash "$filename"
done

for filename in script/curl/*.sh; do
   # shellcheck disable=SC2002
   cat "$filename" | tr -d '\r' > "$filename""1"
   rm "$filename"
   mv "$filename""1" "$filename"
done
for filename in script/curl/*.sh; do
    shellcheck --shell=bash "$filename"
done

for filename in simulate/*.sh; do
   # shellcheck disable=SC2002
   cat "$filename" | tr -d '\r' > "$filename""1"
   rm "$filename"
   mv "$filename""1" "$filename"
done
for filename in simulate/*.sh; do
    shellcheck --shell=bash "$filename"
done

rm -rf test/_result.html

# /C/Users/xcg4444/bin/bats --tap test/*.bats
# C:\Users\info\bin\bats
# /home/markus/bin/bats
echo bats ...
bats --version

bats --tap --timing test/analyse.bats
bats --tap --timing test/averages.bats
bats --tap --timing test/functions.bats
bats --tap --timing test/simulate.bats
bats --tap --timing test/strategies.bats
#bats --verbose-run --tap --timing test/strategies.bats -x --gather-test-outputs-in ~/tmp

# Cleanup
rm -rf 30
rm -rf test/alarm/BEI.txt
rm -rf test/buy/BEI.txt

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."