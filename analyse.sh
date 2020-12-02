#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC
# 1. Parameter: SYMBOLS - List of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA ...'
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query over REST API.
# 4. Parameter: RATED - [overrated|underrated]. Only list low/underrated stocks.
# 5. Parameter: STOCHASTIC: Percentage for stochastic indicator.
# Call example: ./analyse.sh 'ADS.XETRA' 3 online underrated 20
# Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 3 offline underrated 20
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

# Settings for currency formating with 'printf'
export LC_ALL=en_IN.UTF-8
export LANG=en_IN.UTF-8
export LANGUAGE=en_IN.UTF-8

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
ratedParam=$4
stochasticPercentageParam=$5

# Check parameter
if  [ ! -z "${symbolsParam##*[!A-Z0-9. ]*}" ] && [ ! -z "${percentageParam##*[!0-9]*}" ]  && ( [ "$queryParam" = 'offline' ] || [ "$queryParam" = 'online' ] ) && ( [ "$ratedParam" = 'overrated' ] || [ "$ratedParam" = 'underrated' ] ) && [ ! -z "${stochasticPercentageParam##*[!0-9]*}" ] ; then
	echo ""
else
	echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED" | tee -a $resultFile
	echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a $resultFile
	echo " PERCENTAGE: Percentage number between 0..100" | tee -a $resultFile
	echo " QUERY: Query data online|offline" | tee -a $resultFile
	echo " RATED: List only overrated|underrated" | tee -a $resultFile
	echo " STOCHASTIC14: Percentage for stochastic indicator" | tee -a $resultFile
	echo "Example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 3 offline underrated 20" | tee -a $resultFile
	exit
fi

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo "Error: MARKET_STACK_ACCESS_KEY not set!" | tee -a $resultFile
	exit
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

mkdir -p ./out
resultFile=./out/result.txt
touch $resultFile
rm -rf $resultFile

echo "# Analyse parameter" | tee -a $resultFile
echo "Symbols: $symbolsParam" | tee -a $resultFile
echo "Percentage: $percentageParam" | tee -a $resultFile
echo "Query: $queryParam" | tee -a $resultFile
echo "Rated: $ratedParam" | tee -a $resultFile
echo "Stochastic14: $stochasticPercentageParam" | tee -a $resultFile
echo " " >> $resultFile
echo "# Result" >> $resultFile
echo "https://github.com/Hefezopf/stock-analyse/actions" >> $resultFile
echo " " | tee -a $resultFile
echo "# URLs" >> $resultFile
echo "start chrome " >> $resultFile

lesserThen () {
    lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$lesserValue' < '$3')}'; then
		return 1
	else
		return 0		
	fi
}

greaterThen () {
	greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$greaterValue' > '$3')}'; then
		return 1
	else
		return 0
	fi
}

round() {
	return $(printf "%.${2}f" "${1}")
}

averageOfDays() {
	averagePriceList=""
	i=1
	while [ "$i" -lt "${1}" ]; do  # Fill with blank comma seperated data
		averagePriceList=$(echo $averagePriceList ",")
		i=$(( i + 1 ))
	done 

	i=0
	while [ "$i" -le $((100-$1)) ]; 
	do
		headLines=$(echo $((100-$i)))
	    averagePrice=$(head -n$headLines ./data/values.${symbol}.txt | tail -"${1}" | awk '{ sum += $1; } END { print sum/'${1}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
}

stochasticOfDays() {
	stochasticFile=./out/stochastic.txt
	stochasticList=""
	i=1
	while [ "$i" -lt "${1}" ]; do  # Fill with blank comma seperated data
		stochasticList=$(echo $stochasticList ",")
		i=$(( i + 1 ))
	done 

	i=0
	while [ "$i" -le $((100-$1)) ];
	do
		headLines=$(echo $((100-$i)))
		head -n$headLines ./data/values.${symbol}.txt | tail -"${1}" > $stochasticFile
		lastStochastic14Raw=$(head -n 1 $stochasticFile)
		lowestStochastic14Raw=$(sort $stochasticFile | head -n 1)
		highestStochastic14Raw=$(sort -r $stochasticFile | head -n 1)
		greaterThen 1 $highestStochastic14Raw $lowestStochastic14Raw; validStochastik=$?
		if [ "$validStochastik" = 1 ]; then
			# Formula=((C – Ln )/( Hn – Ln )) * 100
			stochasticPrice=$(echo "$lastStochastic14Raw $lowestStochastic14Raw $highestStochastic14Raw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
		else
			stochasticPrice=100
		fi
		stochasticList=$(echo $stochasticList $stochasticPrice",")
		i=$(( i + 1 ))
	done
}

# Get data
for symbol in $symbolsParam
do
	echo "# Get $symbol"
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
	echo "# Analyse $symbol"
	lastRaw=$(head -n1 -q ./data/values.${symbol}.txt)
	#last=$(printf "%'.2f\n" $lastRaw)
    last=$lastRaw

	head -n18 ./data/values.${symbol}.txt > ./out/values18.txt
	average18Raw=$(cat ./out/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	#average18=$(printf "%'.2f\n" $average18Raw)
	average18=$average18Raw
	
	greaterThen $percentageGreaterFactor $last $average18; lastOverAgv18=$?
	lesserThen $percentageLesserFactor $last $average18; lastUnderAgv18=$?

	head -n38 ./data/values.${symbol}.txt > ./out/values38.txt
	average38Raw=$(cat ./out/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	#average38=$(printf "%'.2f\n" $average38Raw)
	average38=$average38Raw
	greaterThen $percentageGreaterFactor $last $average38; lastOverAgv38=$?
    lesserThen $percentageLesserFactor $last $average38;lastUnderAgv38=$?
	
	head -n100 ./data/values.${symbol}.txt > ./out/values100.txt
	average100Raw=$(cat ./out/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	#average100=$(printf "%'.2f\n" $average100Raw)
	average100=$average100Raw
	greaterThen $percentageGreaterFactor $last $average100; lastOverAgv100=$?
	lesserThen $percentageLesserFactor $last $average100; lastUnderAgv100=$?

    # Averages
	greaterThen $percentageGreaterFactor $average18 $average38; agv18OverAgv38=$?
	lesserThen $percentageLesserFactor $average18 $average38; agv18UnderAgv38=$?
	greaterThen $percentageGreaterFactor $average38 $average100; agv38OverAgv100=$?
	lesserThen $percentageLesserFactor $average38 $average100; agv38UnderAgv100=$?
	greaterThen $percentageGreaterFactor $average18 $average100; agv18OverAgv100=$?
	lesserThen $percentageLesserFactor $average18 $average100; agv18UnderAgv100=$?

    # Stochastic
	head -n14 ./data/values.${symbol}.txt > ./out/values14.txt
	lowest14Raw=$(sort ./out/values14.txt | head -n 1)
	highest14Raw=$(sort -r ./out/values14.txt | head -n 1)
    greaterThen 1 $highest14Raw $lowest14Raw; validStochastik=$?
	if [ "$validStochastik" = 1 ]; then
	    # Formula=((C – Ln )/( Hn – Ln )) * 100
		stochastic14=$(echo "$last $lowest14Raw $highest14Raw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
	else
		stochastic14=100
	fi
	round ${stochastic14} 0; stochasticRounded14=$?
	stochasticPercentageLower=$stochasticPercentageParam
	stochasticPercentageUpper=$(echo "$stochasticPercentageLower" | awk '{print (100 - $1)}')

	# Stochastic 14
	stochasticInDays14=14
	stochasticOfDays $stochasticInDays14
	stochasticList14=$stochasticList

	# Average 18
	averageInDays18=18
	averageOfDays $averageInDays18
	averagePriceList18=$averagePriceList

    # Average 38
	averageInDays38=38
	averageOfDays $averageInDays38
	averagePriceList38=$averagePriceList

    # Chart schreiben index.${symbol}.html
	commaPriceListFile=./out/commaPriceListFile.txt
	cat ./data/values.${symbol}.txt | tac > $commaPriceListFile
	commaPriceList=$(cat $commaPriceListFile | awk '{ print $1","; }')
    indexSymbolFile=./out/index.${symbol}.html
	rm -rf $indexSymbolFile
	cp ./js/chart.min.js ./out
	cp ./js/utils.js ./out
	cat ./js/indexPart1.html >> $indexSymbolFile
	echo "'" ${symbol} "'," >> $indexSymbolFile
	cat ./js/indexPart2.html >> $indexSymbolFile
	echo $commaPriceList >> $indexSymbolFile
	cat ./js/indexPart3.html >> $indexSymbolFile	

	echo "'" Average $averageInDays18 "'," >> $indexSymbolFile
	cat ./js/indexPart4.html >> $indexSymbolFile
	echo $averagePriceList18 >> $indexSymbolFile
	cat ./js/indexPart5.html >> $indexSymbolFile	

	echo "'" Average $averageInDays38 "'," >> $indexSymbolFile
	cat ./js/indexPart6.html >> $indexSymbolFile
	echo $averagePriceList38 >> $indexSymbolFile
	cat ./js/indexPart7.html >> $indexSymbolFile

	echo $stochasticList14 >> $indexSymbolFile
	cat ./js/indexPart8.html >> $indexSymbolFile

	echo "<p>&nbsp;Kursdatum:<b>" $(stat -c %y ./data/values.${symbol}.txt | cut -b 1-19) "</b>" >> $indexSymbolFile
	echo "&nbsp;Letzter Kurs:<b>" $last "</b>" >> $indexSymbolFile
	echo "&nbsp;Average 18:<b>" $average18 "</b>" >> $indexSymbolFile
	echo "&nbsp;Average 38:<b>" $average38 "</b>" >> $indexSymbolFile
	echo "&nbsp;Average 100:<b>" $average100 "</b>" >> $indexSymbolFile
	echo "&nbsp;Stochastic 14:<b>" $stochasticRounded14 "</b></p>" >> $indexSymbolFile
	cat ./js/indexPart9.html >> $indexSymbolFile

	fileSize=$(stat -c %s ./data/values.${symbol}.txt)
	# Valid data is higher then 200; otherwise data meight be damaged or unsufficiant
	if [ "$fileSize" > 200 ]; then
		# Overrated
		if [ "$ratedParam" = 'overrated' ]; then
			if [ "$stochasticRounded14" -gt "$stochasticPercentageUpper" ] && [ "$lastOverAgv18" = 1 ] && [ "$lastOverAgv38" = 1 ] && [ "$lastOverAgv100" = 1 ] && 
			   [ "$agv18OverAgv38" = 1 ] && [ "$agv38OverAgv100" = 1 ] && [ "$agv18OverAgv100" = 1 ]; then
				echo "- Overrated: $symbol last $last EUR is more then $percentageLesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR. Stochastic14 is $stochasticRounded14"
				echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
			fi
		fi
	
		# Underrated
		if [ "$ratedParam" = 'underrated' ]; then
			if [ "$stochasticRounded14" -lt "$stochasticPercentageLower" ] && [ "$lastUnderAgv18" = 1 ] && [ "$lastUnderAgv38" = 1 ] && [ "$lastUnderAgv100" = 1 ] && 
			   [ "$agv18UnderAgv38" = 1 ] && [ "$agv38UnderAgv100" = 1 ] && [ "$agv18UnderAgv100" = 1 ]; then
				echo "+ Underrated: $symbol last $last EUR is more then $percentageGreaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR. Stochastic14 is $stochasticRounded14"
				echo -n "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $resultFile
			fi
		fi
	else
	    echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $resultFile
	fi
done

# Cleanup
rm $commaPriceListFile
rm $stochasticFile
rm ./out/values*.txt
outZipFile=out.tar.gz
rm -rf ./out/$outZipFile
tar -zcf $outZipFile out
mv $outZipFile out
