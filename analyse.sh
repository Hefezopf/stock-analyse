#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE [offline|online]
# 1. Parameter: SYMBOLS - Liste of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA ...'
# 2. Parameter: PERCENTAGE - 2 means 2 percent,; 1 if not specified
# 3. Optional parameter: "offline" do not query over REST API. Instead read local files.
# Call example: ./analyse.sh 'ADS.XETRA' 
# Call example: ./analyse.sh 'ADS.XETRA' 2 online 
# Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 2 offline
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

# Settings for currency formating with 'printf'
export LC_ALL=en_IN.UTF-8
export LANG=en_IN.UTF-8
export LANGUAGE=en_IN.UTF-8

# Parameter
symbols=$1
offsetInPercentage=$2
onOfflineQuery=$3

if [[ $onOfflineQuery == 'offline' ]]; then
	echo Offline Query
else
	echo Online Query
fi

lesserFactor=$( echo "100 $offsetInPercentage" | awk '{print ($1 + $2)/100}' )
greaterFactor=$( echo "100 $offsetInPercentage" | awk '{print ($1 - $2)/100}' )

resultFile=./data/result.txt
rm -rf $resultFile

echo -e "Analyse with factor $lesserFactor \n\r" | tee -a $resultFile
echo -e "https://github.com/Hefezopf/stock-analyse/actions \n\r" >> $resultFile
echo -n start chrome " " >> $resultFile

lessThen () {
    lesserValue=$( echo "$lesserFactor $1" | awk '{print $1 * $2}' )
    if awk 'BEGIN {exit !('$lesserValue' < '$2')}'; then
		return 1
	fi
}

greaterThen () {
	greaterValue=$( echo "$greaterFactor $1" | awk '{print $1 * $2}' )
    if awk 'BEGIN {exit !('$greaterValue' > '$2')}'; then
		return 1
	fi
}

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo Error: MARKET_STACK_ACCESS_KEY not set!
	exit
fi

# Get data
for symbol in $symbols
do
	echo "## Get $symbol ##"
	if [[ $onOfflineQuery == 'offline' ]];then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
done

echo " "

# Analyse data
for symbol in $symbols
do
	echo "## Analyse $symbol ##"
	lastRaw=$(head -n1 -q ./data/values.${symbol}.txt)
	last=$(printf "%'.2f\n" $lastRaw)

	head -n18 ./data/values.${symbol}.txt > ./data/values18.txt
	average18Raw=$(cat ./data/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	average18=$(printf "%'.2f\n" $average18Raw)
	
	greaterThen $last $average18; lastOverAgv18=$?
	lessThen $last $average18;	lastUnderAgv18=$?

	head -n38 ./data/values.${symbol}.txt > ./data/values38.txt
	average38Raw=$(cat ./data/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	average38=$(printf "%'.2f\n" $average38Raw)
	greaterThen $last $average38; lastOverAgv38=$?
    lessThen $last $average38;	lastUnderAgv38=$?
	
	head -n100 ./data/values.${symbol}.txt > ./data/values100.txt
	average100Raw=$(cat ./data/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	average100=$(printf "%'.2f\n" $average100Raw)
	greaterThen $last $average100;	lastOverAgv100=$?
	lessThen $last $average100; lastUnderAgv100=$?

	greaterThen $average18 $average38; agv18OverAgv38=$?
	lessThen $average18 $average38; agv18UnderAgv38=$?
	greaterThen $average38 $average100; agv38OverAgv100=$?
	lessThen $average38 $average100; agv38UnderAgv100=$?
	greaterThen $average18 $average100; agv18OverAgv100=$?
	lessThen $average18 $average100; agv18UnderAgv100=$?

	fileSize=$(stat -c %s ./data/values.${symbol}.txt)
	# Valid data is higher then 200; otherwise data meight be damaged or unsufficiant
	if [[ $fileSize > 200 ]];then
		if [ $lastOverAgv18 == 1 ] && [ $lastOverAgv38 == 1 ] && [ $lastOverAgv100 == 1 ] && 
		[ $agv18OverAgv38 == 1 ] && [ $agv38OverAgv100 == 1 ] && [ $agv18OverAgv100 == 1 ];
		then
			echo "- Overrated: $symbol last $last EUR is more then $lesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR"
			echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
		fi
		
		if [ $lastUnderAgv18 == 1 ] && [ $lastUnderAgv38 == 1 ] && [ $lastUnderAgv100 == 1 ] && 
		[ $agv18UnderAgv38 == 1 ] && [ $agv38UnderAgv100 == 1 ] && [ $agv18UnderAgv100 == 1 ];
		then
			echo "+ Underrated: $symbol last $last EUR is more then $greaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR"
			echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
		fi
	else
	    echo "! File sizeof $symbol id suspicious: $fileSize kb"
	fi
done