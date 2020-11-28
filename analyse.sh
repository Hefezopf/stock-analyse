#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED
# 1. Parameter: SYMBOLS - List of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA ...'
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent; 1 if not specified.
# 3. Optional parameter: QUERY - [online|offline] 'offline' do not query over REST API. Instead read local files.
# 4. Optional parameter: RATED - Looking for what rating? [overrated|underrated]. If 'underrated', only list low/underrated stocks.
# Call example: ./analyse.sh 'ADS.XETRA' 
# Call example: ./analyse.sh 'ADS.XETRA' 3 online 
# Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 3 offline underrated
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

# Settings for currency formating with 'printf'
export LC_ALL=en_IN.UTF-8
export LANG=en_IN.UTF-8
export LANGUAGE=en_IN.UTF-8

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
ratedParam=$4

# Check parameter
#if  ( [ "$queryParam" = 'offline' ] || [ "$queryParam" = 'online' ] ) && ( [ "$ratedParam" = 'overrated' ] || [ "$ratedParam" = 'underrated' ] ); then
if  [ ! -z "${symbolsParam##*[!A-Z0-9. ]*}" ] && [ ! -z "${percentageParam##*[!0-9]*}" ]  && ( [ "$queryParam" = 'offline' ] || [ "$queryParam" = 'online' ] ) && ( [ "$ratedParam" = 'overrated' ] || [ "$ratedParam" = 'underrated' ] ); then
#if [[ ! -z "${symbolsParam##*[!A-Z0-9. ]*}" ]] && [[ ! -z "${percentageParam##*[!0-9]*}" ]]  && ( [[ "$queryParam" = 'offline' ]] || [[ "$queryParam" = 'online' ]] ) && ( [[ "$ratedParam" = 'overrated' ]] || [[ "$ratedParam" = 'underrated' ]] ); then
	echo ""
else
	echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED" | tee -a $resultFile
	echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a $resultFile
	echo " PERCENTAGE: Percentage number between 0..100" | tee -a $resultFile
	echo " QUERY: Query data online|offline" | tee -a $resultFile
	echo " RATED: List only overrated|underrated" | tee -a $resultFile
	echo "Example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 3 offline underrated" | tee -a $resultFile
	exit
fi

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo "Error: MARKET_STACK_ACCESS_KEY not set!" | tee -a $resultFile
	exit
fi

lesserFactor=$( echo "100 $percentageParam" | awk '{print ($1 + $2)/100}' )
greaterFactor=$( echo "100 $percentageParam" | awk '{print ($1 - $2)/100}' )

resultFile=./data/result.txt
rm -rf $resultFile

echo "Analyse parameters:" | tee -a $resultFile
echo " Symbols: $symbolsParam" | tee -a $resultFile
echo " Percentage: $percentageParam" | tee -a $resultFile
echo " Query: $queryParam" | tee -a $resultFile
echo " Rated: $ratedParam" | tee -a $resultFile
echo " " | tee -a $resultFile
echo "Results here:" >> $resultFile
echo " https://github.com/Hefezopf/stock-analyse/actions \n\r" >> $resultFile
echo -n "start chrome " >> $resultFile

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

# Get data
for symbol in $symbolsParam
do
	echo "## Get $symbol ##"
	if [ "$queryParam" = 'offline' ]; then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
done

echo " "

# Analyse data
for symbol in $symbolsParam
do
	echo "## Analyse $symbol ##"
	lastRaw=$(head -n1 -q ./data/values.${symbol}.txt)
	#last=$(printf "%'.2f\n" $lastRaw)
    last=$lastRaw

	head -n18 ./data/values.${symbol}.txt > ./data/values18.txt
	average18Raw=$(cat ./data/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	#average18=$(printf "%'.2f\n" $average18Raw)
	average18=$average18Raw
	
	greaterThen $last $average18; lastOverAgv18=$?
	lessThen $last $average18;	lastUnderAgv18=$?

	head -n38 ./data/values.${symbol}.txt > ./data/values38.txt
	average38Raw=$(cat ./data/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	#average38=$(printf "%'.2f\n" $average38Raw)
	average38=$average38Raw
	greaterThen $last $average38; lastOverAgv38=$?
    lessThen $last $average38;	lastUnderAgv38=$?
	
	head -n100 ./data/values.${symbol}.txt > ./data/values100.txt
	average100Raw=$(cat ./data/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	#average100=$(printf "%'.2f\n" $average100Raw)
	average100=$average100Raw
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
	if [ "$fileSize" > 200 ]; then
		# Overrated
		if [ "$ratedParam" = 'overrated' ]; then
			if [ "$lastOverAgv18" = 1 ] && [ "$lastOverAgv38" = 1 ] && [ "$lastOverAgv100" = 1 ] && 
			   [ "$agv18OverAgv38" = 1 ] && [ "$agv38OverAgv100" = 1 ] && [ "$agv18OverAgv100" = 1 ]; then
				echo "- Overrated: $symbol last $last EUR is more then $lesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR"
				echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
			fi
		fi
	
		# Underrated
		if [ "$ratedParam" = 'underrated' ]; then
			if [ "$lastUnderAgv18" = 1 ] && [ "$lastUnderAgv38" = 1 ] && [ "$lastUnderAgv100" = 1 ] && 
			   [ "$agv18UnderAgv38" = 1 ] && [ "$agv38UnderAgv100" = 1 ] && [ "$agv18UnderAgv100" = 1 ]; then
				echo "+ Underrated: $symbol last $last EUR is more then $greaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR"
				echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
			fi
		fi
	else
	    echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $resultFile
	fi
done