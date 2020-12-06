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

# Prepare
mkdir -p out
OUT_ZIP_FILE=out.tar.gz
rm -rf out/$OUT_ZIP_FILE
touch out/$OUT_ZIP_FILE
OUT_RESULT_FILE=out/result.html
rm -rf $OUT_RESULT_FILE
HTML_END=$(echo "</p><p>Thanks</p></div></body></html>" )
START_TIME_MEASUREMENT=$(date +%s);

# Email header
htmlHeader=$(echo "<html><head><style>.colored {color: blue;}#body {font-size: 14px;}@media screen and (min-width: 500px)</style></head><body><div id="body"><p>Stock Analyse,</p><p>")
echo $htmlHeader > $OUT_RESULT_FILE

# Check parameter
if  [ ! -z "${symbolsParam##*[!A-Z0-9. ]*}" ] && [ ! -z "${percentageParam##*[!0-9]*}" ]  && ( [ "$queryParam" = 'offline' ] || [ "$queryParam" = 'online' ] ) && ( [ "$ratedParam" = 'overrated' ] || [ "$ratedParam" = 'underrated' ] ) && [ ! -z "${stochasticPercentageParam##*[!0-9]*}" ] ; then
	echo ""
else
	echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " PERCENTAGE: Percentage number between 0..100" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " QUERY: Query data online|offline" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " RATED: List only overrated|underrated" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " STOCHASTIC14: Percentage for stochastic indicator" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo "Example: ./analyse.sh 'ADS.XETRA ALV.XETRA' 3 offline underrated 20" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
    echo $HTML_END >> $OUT_RESULT_FILE
	exit
fi

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo "Error: MARKET_STACK_ACCESS_KEY not set!" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
    echo $HTML_END >> $OUT_RESULT_FILE
	exit
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

echo "# Analyse parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Symbols: $symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage: $percentageParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Query: $queryParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Rated: $ratedParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic14: $stochasticPercentageParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo " " >> $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "# Result" >> $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "https://github.com/Hefezopf/stock-analyse/actions" >> $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo " " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "# URLs" >> $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "start chrome " >> $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE

# LesserThenWithFactor function: Input is factor($1), firstCompareValue($2), secondCompareValue($3)
LesserThenWithFactor() {
    _lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$_lesserValue' < '$3')}'; then
		return 1
	else
		return 0		
	fi
}

# GreaterThenWithFactor function: Input is factor($1), firstCompareValue($2), secondCompareValue($3)
GreaterThenWithFactor() {
	_greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$_greaterValue' > '$3')}'; then
		return 1
	else
		return 0
	fi
}

# RoundNumber function: Input is floatNumber($1), digitsAfterComma($2)
RoundNumber() {
	return $(printf "%.${2}f" "${1}")
}

# AverageOfDays function:
# Input is amountOfDays($1)
# Output: averagePriceList is comma separted list
AverageOfDays() {
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
	    averagePrice=$(head -n$headLines data/values.${symbol}.txt | tail -"${1}" | awk '{ sum += $1; } END { print sum/'${1}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
}

# StochasticOfDays function: Input is amountOfDays($1)
# Output: stochasticQuoteList is comma separted list
StochasticOfDays() {
	stochasticFile=out/stochastic.txt
	stochasticQuoteList=""
	i=1
	# Fill with blank comma seperated data
	while [ "$i" -lt "${1}" ]; do 
		stochasticQuoteList=$(echo $stochasticQuoteList ",")
		i=$(( i + 1 ))
	done 

	i=0
	# TODO optimize not 100 loop?!
	while [ "$i" -le $((100-$1)) ];
	do
		headLines=$(echo $((100-$i)))
		head -n$headLines data/values.${symbol}.txt | tail -"${1}" > $stochasticFile
		lastStochasticRaw=$(head -n 1 $stochasticFile)
		lowestStochasticRaw=$(sort -g $stochasticFile | head -n 1)
		highestStochasticRaw=$(sort -gr $stochasticFile | head -n 1)
		GreaterThenWithFactor 1 $highestStochasticRaw $lowestStochasticRaw; validStochastik=$?
		if [ "$validStochastik" = 1 ]; then
			# Formula=((C – Ln )/( Hn – Ln )) * 100
			lastStochasticQuote=$(echo "$lastStochasticRaw $lowestStochasticRaw $highestStochasticRaw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
		else
			lastStochasticQuote=100
		fi
	    RoundNumber ${lastStochasticQuote} 0; lastStochasticQuoteRounded=$?
		stochasticQuoteList=$(echo $stochasticQuoteList $lastStochasticQuoteRounded",")
		i=$(( i + 1 ))
	done
}

# ProgressBar function: Input is currentState($1) and totalState($2)
ProgressBar() {
	# Process data
	_progress_=$(echo $((${1}*100/${2}*100)))
	_progress=$(echo $(($_progress_/100)))
	_done_=$(echo $((${_progress}*4)))
	_done=$(echo $(($_done_/10)))
    _left=$(echo $((40-$_done)))
	# Build progressbar string lengths
	_fill=$(printf "%${_done}s")
	_empty=$(printf "%${_left}s")                         
	# Progress: ######################################## 100%
	if [ $(uname) = 'MINGW64_NT-10.0-18363' ]; then
		echo -n $(printf "\r${_fill// /#}${_empty// /-} ${_progress}%%")
	fi
}



stochasticQuoteList=$(echo " , , , , 4, 9, 6, 8,")
# Revers and output the last x numbers
stochasticQuoteList=$(echo "$stochasticQuoteList" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 "," $5 }' )
echo mmmmmmmm $stochasticQuoteList
lowValue=8
inc=0
#IFS=',' read -ra ADDR <<< "$stochasticQuoteList"
IFS=',' read -ra ADDR <<EOL
$stochasticQuoteList
EOL
echo $ADDR

for i in "${ADDR[@]}"; do
	i=$(echo "$i" | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }')
	#echo iii $i und lowValue $lowValue
	if [ "$i" -lt "$lowValue" ]; then
		inc=$(($inc + 1))
	fi
done
if [ "$inc" -lt 4 ]; then
	echo So oft: $inc inden letzten 4 Quotes unter Schwellwert: $lowValue
fi
exit


# Get data
for symbol in $symbolsParam
do
	echo "# Get $symbol"
	if [ "$queryParam" = 'offline' ]; then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > data/values.${symbol}.txt
	fi
done

echo "<br>" >> $OUT_RESULT_FILE

# Analyse data for each symbol
for symbol in $symbolsParam
do
	#
	# Gather data
	#

    echo " "
	echo "# Analyse $symbol"
	lastRaw=$(head -n1 -q data/values.${symbol}.txt)
	#last=$(printf "%'.2f\n" $lastRaw)
    last=$lastRaw

	head -n18 data/values.${symbol}.txt > out/values18.txt
	average18Raw=$(cat out/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	#average18=$(printf "%'.2f\n" $average18Raw)
	average18=$average18Raw

    ProgressBar 1 6

	GreaterThenWithFactor $percentageGreaterFactor $last $average18; lastOverAgv18=$?
	LesserThenWithFactor $percentageLesserFactor $last $average18; lastUnderAgv18=$?

	head -n38 data/values.${symbol}.txt > out/values38.txt
	average38Raw=$(cat out/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	#average38=$(printf "%'.2f\n" $average38Raw)
	average38=$average38Raw
	GreaterThenWithFactor $percentageGreaterFactor $last $average38; lastOverAgv38=$?
    LesserThenWithFactor $percentageLesserFactor $last $average38;lastUnderAgv38=$?
	
	head -n100 data/values.${symbol}.txt > out/values100.txt
	average100Raw=$(cat out/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	#average100=$(printf "%'.2f\n" $average100Raw)
	average100=$average100Raw
	GreaterThenWithFactor $percentageGreaterFactor $last $average100; lastOverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $last $average100; lastUnderAgv100=$?

    # Averages
	GreaterThenWithFactor $percentageGreaterFactor $average18 $average38; agv18OverAgv38=$?
	LesserThenWithFactor $percentageLesserFactor $average18 $average38; agv18UnderAgv38=$?
	GreaterThenWithFactor $percentageGreaterFactor $average38 $average100; agv38OverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $average38 $average100; agv38UnderAgv100=$?
	GreaterThenWithFactor $percentageGreaterFactor $average18 $average100; agv18OverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $average18 $average100; agv18UnderAgv100=$?
 
    ProgressBar 2 6

    # Calculate all Stochastic 14 values
	stochasticInDays14=14
	StochasticOfDays $stochasticInDays14
	stochasticQuoteList14=$stochasticQuoteList

    ProgressBar 3 6

	# Stochastics percentage
	stochasticPercentageLower=$stochasticPercentageParam
	stochasticPercentageUpper=$(echo "$stochasticPercentageLower" | awk '{print (100 - $1)}')

	# Average 18
	averageInDays18=18
	AverageOfDays $averageInDays18
	averagePriceList18=$averagePriceList

	ProgressBar 4 6

    # Average 38
	averageInDays38=38
	AverageOfDays $averageInDays38
	averagePriceList38=$averagePriceList

	ProgressBar 5 6

    # Average 100
	averageInDays100=100
	AverageOfDays $averageInDays100
	averagePriceList100=$averagePriceList

	ProgressBar 6 6

	#
	# Apply strategies
	#

	# Valid data is higher then 200; otherwise data meight be damaged or unsufficiant
	fileSize=$(stat -c %s data/values.${symbol}.txt)
	if [ "$fileSize" -gt 200 ]; then
		# Overrated
		resultOverrated=""
		if [ "$ratedParam" = 'overrated' ]; then
			if [ "$lastStochasticQuoteRounded" -gt "$stochasticPercentageUpper" ] && [ "$lastOverAgv18" = 1 ] && [ "$lastOverAgv38" = 1 ] && [ "$lastOverAgv100" = 1 ] && 
			   [ "$agv18OverAgv38" = 1 ] && [ "$agv38OverAgv100" = 1 ] && [ "$agv18OverAgv100" = 1 ]; then
				resultOverrated="- Overrated: $symbol last $last EUR is more then $percentageLesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR. Stochastic14 is $lastStochasticQuoteRounded"
				echo $resultOverrated
				echo "<br>" >> $OUT_RESULT_FILE
				echo "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $OUT_RESULT_FILE
				echo "<br>" >> $OUT_RESULT_FILE
			fi
		fi
	
		# Underrated
		resultUnderrated=""
		if [ "$ratedParam" = 'underrated' ]; then
			if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ] && [ "$lastUnderAgv18" = 1 ] && [ "$lastUnderAgv38" = 1 ] && [ "$lastUnderAgv100" = 1 ] && 
			   [ "$agv18UnderAgv38" = 1 ] && [ "$agv38UnderAgv100" = 1 ] && [ "$agv18UnderAgv100" = 1 ]; then
				resultUnderrated="+ Underrated: $symbol last $last EUR is more then $percentageGreaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR. Stochastic14 is $lastStochasticQuoteRounded"
				echo $resultUnderrated
				echo "<br>" >> $OUT_RESULT_FILE
				echo "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $OUT_RESULT_FILE
				echo "<br>" >> $OUT_RESULT_FILE
			fi
		fi
	
		# Low stochastik

echo stochasticQuoteList $stochasticQuoteList



# # Revers and output the last x numbers
# stochasticQuoteList=$(echo "$stochasticQuoteList" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 "," $5 }' )
# echo mmmmmmmm $stochasticQuoteList
# lowValue=8
# inc=0
# #IFS=',' read -ra ADDR <<< "$stochasticQuoteList"
# IFS=',' read -ra ADDR <<"$stochasticQuoteList"
# $stochasticQuoteList

# for i in "${ADDR[@]}"; do
# 	i=$(echo "$i" | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }')
# 	echo iii $i und lowValue $lowValue
# 	if [ "$i" -lt "$lowValue" ]; then
# 		inc=$(($inc + 1))
# 	fi
# done
# echo So oft: $inc inden letzten 4 Quotes unter Schwellwert: $lowValue



		resultLowStochastik=""
		if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ]; then
			resultLowStochastik="+ Low stochastik: $symbol has $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
			echo $resultLowStochastik
			echo "<br>" >> $OUT_RESULT_FILE
			echo "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $OUT_RESULT_FILE
			echo "<br>" >> $OUT_RESULT_FILE
		fi
	else
	    echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $OUT_RESULT_FILE
		echo "<br>" >> $OUT_RESULT_FILE
	fi

	#
	# Output
	#

    # Writing chart index.${symbol}.html
	commaPriceListFile=out/commaPriceListFile.txt
	cat data/values.${symbol}.txt | tac > $commaPriceListFile
	commaPriceList=$(cat $commaPriceListFile | awk '{ print $1","; }')
    indexSymbolFile=out/index.${symbol}.html
	rm -rf $indexSymbolFile
	cp js/chart.min.js out
	cp js/utils.js out
	cat js/indexPart1.html >> $indexSymbolFile
	echo "'" ${symbol} "'," >> $indexSymbolFile
	cat js/indexPart2.html >> $indexSymbolFile
	echo $commaPriceList >> $indexSymbolFile
	cat js/indexPart3.html >> $indexSymbolFile	

	echo "'" Average $averageInDays18 "'," >> $indexSymbolFile
	cat js/indexPart4.html >> $indexSymbolFile
	echo $averagePriceList18 >> $indexSymbolFile
	cat js/indexPart5.html >> $indexSymbolFile	

	echo "'" Average $averageInDays38 "'," >> $indexSymbolFile
	cat js/indexPart6.html >> $indexSymbolFile
	echo $averagePriceList38 >> $indexSymbolFile
	cat js/indexPart7.html >> $indexSymbolFile	

	echo "'" Average $averageInDays100 "'," >> $indexSymbolFile
	cat js/indexPart8.html >> $indexSymbolFile
	echo $averagePriceList100 >> $indexSymbolFile
	cat js/indexPart9.html >> $indexSymbolFile

	echo $stochasticQuoteList14 >> $indexSymbolFile
	cat js/indexPart10.html >> $indexSymbolFile

	echo "<p>Kursdatum:<b>" $(stat -c %y data/values.${symbol}.txt | cut -b 1-10) "</b>" >> $indexSymbolFile
	echo "&nbsp;Schluss Kurs:<b>" $last "&#8364;</b>" >> $indexSymbolFile
	echo "&nbsp;Average 18:<b>" $average18 "&#8364;</b>" >> $indexSymbolFile
	echo "&nbsp;Average 38:<b>" $average38 "&#8364;</b>" >> $indexSymbolFile
	echo "&nbsp;Average 100:<b>" $average100 "&#8364;</b>" >> $indexSymbolFile
	echo "&nbsp;Stochastic 14:<b>" $lastStochasticQuoteRounded "</b></p>" >> $indexSymbolFile
	echo "<p>Result:</p>" >> $indexSymbolFile
	echo "<p><b>" $resultUnderrated "</b></p>" >> $indexSymbolFile
	cat js/indexPart11.html >> $indexSymbolFile

	# Store list of files for later (tar/zip)
	indexSymbolFileList=$(echo $indexSymbolFileList " " $indexSymbolFile)

done

echo $HTML_END >> $OUT_RESULT_FILE

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo " "
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Cleanup
rm $commaPriceListFile
rm $stochasticFile
rm out/values*.txt
tar -zcf $OUT_ZIP_FILE $indexSymbolFileList
mv $OUT_ZIP_FILE out
