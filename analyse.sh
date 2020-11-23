#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS [offline]
# SYMBOLS - Liste of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA'
# Optional parameter "offline" do not query over REST API. Instead read local files.
# 1. Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA'
# 2. Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA' offline
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

result_file=./data/result.txt
rm -rf $result_file

less_then () {
    if awk 'BEGIN {exit !('$1' < '$2')}'; then
		return 1
	fi
}

greater_then () {
    if awk 'BEGIN {exit !('$1' > '$2')}'; then
		return 1
	fi
}

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo Error: MARKET_STACK_ACCESS_KEY not set!
	exit
fi

if [[ $2 == 'offline' ]]; then
	echo Offline Query
else
	echo Online Query
fi

symbols=$1	
for symbol in $symbols
do
	echo "## $symbol ##"
	if [[ $2 == 'offline' ]]; then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
	
	cp ./data/values.${symbol}.txt ./data/values100.txt
	last=$(head -n1 -q data/values100.txt)
	
	head -n18 ./data/values.${symbol}.txt > ./data/values18.txt
	average18=$(cat ./data/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	greater_then $last $average18; over18=$?
	less_then $last $average18;	under18=$?

	head -n38 ./data/values.${symbol}.txt > ./data/values38.txt
	average38=$(cat ./data/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	greater_then $last $average38; over38=$?
    less_then $last $average38;	under38=$?
	
	average100=$(cat ./data/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	greater_then $last $average100;	over100=$?
	less_then $last $average100; under100=$?
	
	if [ $over18 == 1 ] && [ $over38 == 1 ] && [ $over100 == 1 ]; then
		echo "-------> Overrated: $symbol $last over average 18: $average18 and average 38: $average38 and over average 100: $average100"
		echo Overrated: "http://www.google.com/search?tbm=fin&q=${symbol}" >> $result_file
	fi
	
	if [ $under18 == 1 ] && [ $under38 == 1 ] && [ $under100 == 1 ]; then
		echo "++++++++> Underrated: $symbol $last under average 18: $average18 and under average 38: $average38 and under average 100: $average100"
		echo Underrated: "http://www.google.com/search?tbm=fin&q=${symbol}" >> $result_file
	fi
	
	echo " "
done
