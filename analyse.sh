#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE [offline|online]
# 1. Parameter SYMBOLS - Liste of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA'
# 2.  Parameter PERCENTAGE - 0.12 means 12 Percent,; 0 if not specified
# 3. Optional parameter "offline" do not query over REST API. Instead read local files.
# Call example: ./analyse.sh 'ADS.XETRA' 
# Call example: ./analyse.sh 'ADS.XETRA' 0.09 online 
# Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA' 0.11 offline
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

# 0.12 means 12 Percent
offsetInPercentage=$2
lesserFactor=$( echo "1 $offsetInPercentage" | awk '{print $1 + $2}' )
greaterFactor=$( echo "1 $offsetInPercentage" | awk '{print $1 - $2}' )

result_file=./data/result.txt
rm -rf $result_file
#touch $result_file

less_then () {
    lesserValue=$( echo "$lesserFactor $1" | awk '{print $1 * $2}' )
    if awk 'BEGIN {exit !('$lesserValue' < '$2')}'; then
		return 1
	fi
}

greater_then () {
	greaterValue=$( echo "$greaterFactor $1" | awk '{print $1 * $2}' )
    if awk 'BEGIN {exit !('$greaterValue' > '$2')}'; then
		return 1
	fi
}

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo Error: MARKET_STACK_ACCESS_KEY not set!
	exit
fi

if [[ $3 == 'offline' ]]; then
	echo Offline Query
else
	echo Online Query
fi

echo Analyse with factor $lesserFactor | tee -a $result_file

symbols=$1	
for symbol in $symbols
do
	echo "## $symbol ##"
	if [[ $3 == 'offline' ]]; then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
	
	last=$(head -n1 -q ./data/values.${symbol}.txt)
	
	head -n18 ./data/values.${symbol}.txt > ./data/values18.txt
	average18=$(cat ./data/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	greater_then $last $average18; over18=$?
	less_then $last $average18;	under18=$?

	head -n38 ./data/values.${symbol}.txt > ./data/values38.txt
	average38=$(cat ./data/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	greater_then $last $average38; over38=$?
    less_then $last $average38;	under38=$?
	
	head -n100 ./data/values.${symbol}.txt > ./data/values100.txt
	average100=$(cat ./data/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	greater_then $last $average100;	over100=$?
	less_then $last $average100; under100=$?

	if [ $over18 == 1 ] && [ $over38 == 1 ] && [ $over100 == 1 ]; then
		echo "-------> Overrated: $symbol $last EUR is $lesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR"
		echo -e Overrated: "http://www.google.com/search?tbm=fin&q=${symbol}\n\r" >> $result_file
	fi
	
	if [ $under18 == 1 ] && [ $under38 == 1 ] && [ $under100 == 1 ]; then
		echo "++++++++> Underrated: $symbol $last EUR is $greaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR"
		echo -e Underrated: "http://www.google.com/search?tbm=fin&q=${symbol}\n\r" >> $result_file
	fi
	
	echo " "
done
