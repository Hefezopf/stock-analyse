#!/bin/bash

# Runs local tests for all bats files: test/*.bats
# Using installation from /media/markus/BigBerta/code/stock-analyse/script/install-bats.sh

# https://github.com/bats-core/bats-core
# https://github.com/ztombol/bats-assert

# Windows bash:
# cd /D/code
# git clone https://github.com/bats-core/bats-core.git
# git clone https://github.com/bats-core/bats-assert.git
# cd bats-core
# ./install.sh ~
# 4 dirs are created in ~ (/c/Users/info/bin/bats)
# /libexec, /bin, /share and /lib
# bats --version

# Mint bash:
# . /media/markus/BigBerta/code/stock-analyse/script/install-bats.sh
# Installation under /home/markus/test/test_helper/batscore/bin
# ./bats -v

# To get rid of carrage returns, may run:
# sed -i 's/\r//g' script/constants.sh
# sed -i 's/\r//g' simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh

# Call: . test.sh
# For time messurement use 'gnomon'
# npm install -g gnomon
# Call: . test.sh | gnomon --medium=1.0 --high=4.0 --ignore-blank --real-time=100

START_TIME_MEASUREMENT=$(date +%s);

 echo html-validate ...
if html-validate --config .htmlvalidate.json out/_result.html
then
    echo html-validate out/_result.html
else
    echo ERROR: echo html-validate ... 1>&2
    read -n1 -r -p "Hit ANY KEY!"
    #exit 1
fi

if html-validate --config .htmlvalidate.json out/BEI.html
then
    echo html-validate out/BEI.html
else
    echo ERROR: echo html-validate ... 1>&2
    read -n 1 -r -p "Hit ANY KEY!"
    #exit 2
fi

if html-validate --config .htmlvalidate.json simulate/out/_simulate.html
then
    echo html-validate simulate/out/_simulate.html
else
    echo ERROR: echo html-validate ... 1>&2
    read -n 1 -r -p "Hit ANY KEY!"
    #exit 3
fi

if html-validate --config .htmlvalidate.json simulate/out/BEI.html
then
    echo html-validate simulate/out/BEI.html
else
    echo ERROR: echo html-validate ... 1>&2
    read -n 1 -r -p "Hit ANY KEY!"
    #exit 4
fi

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
   chmod +x "$filename"
done
for filename in simulate/*.sh; do
    shellcheck --shell=bash "$filename"
done

rm -rf test/_result.html

# /C/Users/xcg4444/bin/bats --tap test/*.bats
# C:\Users\info\bin\bats
# /home/markus/bin/bats
# /home/markus/test/test_helper/batscore/bin/bats'
echo bats ...
alias bats='/home/markus/test/test_helper/batscore/bin/bats'
#./bats --version
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