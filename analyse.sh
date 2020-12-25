#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'ADS ALV BAS ...'
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query over REST API.
# 4. Parameter: RATED - [overrated|underrated]. Only list low/underrated stocks.
# 5. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 6. Parameter: RSI: Quote for RSI indicator.
# Call example: ./analyse.sh 'ADS ALV' 3 online underrated 9 30
# Call example: ./analyse.sh 'ADS' 1 offline underrated 9 30
#
# Set MARKET_STACK_ACCESS_KEY and MARKET_STACK_ACCESS_KEY2 as Env Variable

# Import functions
. ./script/functions.sh

# Import strategies
. ./script/strategies.sh

# Settings for currency formating with 'printf'
export LC_ALL=en_IN.UTF-8

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
ratedParam=$4
stochasticPercentageParam=$5
RSIQuoteParam=$6

# Prepare
mkdir -p out
mkdir -p temp
OUT_ZIP_FILE=_out.tar.gz
rm -rf out/$OUT_ZIP_FILE
touch out/$OUT_ZIP_FILE
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
reportedSymbolFileList=""
#reportedSymbolFileList=$OUT_RESULT_FILE
TICKER_NAMES_FILE=data/_ticker_names.txt
# Email header
HTML_RESULT_FILE_HEADER=$(echo "<html><head><link rel=\"shortcut icon\" type=\"image/ico\" href=\"_favicon.ico\" /><title>Result</title><style>.colored {color: blue;}#body {font-size: 14px;}@media screen and (min-width: 500px)</style></head><body><div><p>Stock Analyse,</p><p>")
echo $HTML_RESULT_FILE_HEADER > $OUT_RESULT_FILE
HTML_RESULT_FILE_END=$(echo "</p><p>Thanks</p></div></body></html>" )
COMDIRECT_URL_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?timeSpan=6M&chartType=MOUNTAIN&useFixAverage=false&freeAverage0=100&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&ID_NOTATION="
START_TIME_MEASUREMENT=$(date +%s);

# Check for duplicate symbol in cmd
echo "$symbolsParam" | tr " " "\n" | sort | uniq -c | grep -qv '^ *1 ' && echo $symbolsParam | tr " " "\n" | sort | uniq -c  | tee -a $OUT_RESULT_FILE && echo "Duplicate symbol in parameter list!" | tee -a $OUT_RESULT_FILE && echo "<br>" >> $OUT_RESULT_FILE && exit 4

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" $percentageParam $queryParam $ratedParam $stochasticPercentageParam $RSIQuoteParam $OUT_RESULT_FILE

if [ -z "$MARKET_STACK_ACCESS_KEY" ] || [ -z "$MARKET_STACK_ACCESS_KEY2" ]; then
	echo "Error: MARKET_STACK_ACCESS_KEY or MARKET_STACK_ACCESS_KEY2 not set!" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
    echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE
	exit 6
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

echo "# Analyse Parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$(( countSymbols + 1 ))
echo "Symbols($countSymbols):$symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage:$percentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Query:$queryParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Rated:$ratedParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic:$stochasticPercentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI:$RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "<br><br># Result<br>" >> $OUT_RESULT_FILE
echo "<a href="https://github.com/Hefezopf/stock-analyse/actions" target=_blank>Github Action</a><br><br>" >> $OUT_RESULT_FILE
echo "# URLs<br>" >> $OUT_RESULT_FILE

# Analyse data for each symbol
for symbol in $symbolsParam
do
	# Curl symbol name
	CurlSymbolName $symbol $TICKER_NAMES_FILE 14

	# Get stock data
	echo ""
	echo "# Get $symbolName"
	if [ "$queryParam" = 'online' ]; then
	    tag=$(date +"%s") # Second -> date +"%s" ; Day -> date +"%d"
		evenodd=$(( $tag  % 2 ))
		if [ "$evenodd" -eq 0 ]; then
		    ACCESS_KEY=${MARKET_STACK_ACCESS_KEY}
		else
			ACCESS_KEY=${MARKET_STACK_ACCESS_KEY2}
		fi
		DATA_FILE=data/${symbol}.txt
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${ACCESS_KEY}&exchange=XETRA&symbols=${symbol}.XETRA" | jq '.data[].close' > $DATA_FILE
		fileSize=$(stat -c %s $DATA_FILE)
		if [ "${fileSize}" -eq "0" ]; then
			echo "!Symbol NOT found online on marketstack.com: $symbol" | tee -a $OUT_RESULT_FILE
			echo "<br>" >> $OUT_RESULT_FILE
			rm -rf $DATA_FILE
		fi
	fi

	symbolName=$(grep -w "$symbol " $TICKER_NAMES_FILE)

	CreateCmdAnalyseHyperlink

	ProgressBar 1 8

    DATA_FILE=data/${symbol}.txt
	lastRaw=$(head -n1 -q $DATA_FILE)
	last=$(printf "%.2f" $lastRaw)
	# Check for unknown or not fetched symbol in cmd or on marketstack.com
	if [ "${#lastRaw}" -eq 0 ]; then
		echo "!Symbol $symbol NOT found offline in data/$symbol.txt: Try to query 'online'!" | tee -a $OUT_RESULT_FILE
		echo "<br>" >> $OUT_RESULT_FILE
		# continue with next symbol in the list
		continue
	fi

	head -n18 $DATA_FILE > temp/values18.txt
	average18Raw=$(cat temp/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	average18=$(printf "%.2f" $average18Raw)

    ProgressBar 2 8

	GreaterThenWithFactor $percentageGreaterFactor $last $average18; lastOverAgv18=$?
	LesserThenWithFactor $percentageLesserFactor $last $average18; lastUnderAgv18=$?

	head -n38 $DATA_FILE > temp/values38.txt
	average38Raw=$(cat temp/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	average38=$(printf "%.2f" $average38Raw)
	GreaterThenWithFactor $percentageGreaterFactor $last $average38; lastOverAgv38=$?
    LesserThenWithFactor $percentageLesserFactor $last $average38;lastUnderAgv38=$?
	
	head -n100 $DATA_FILE > temp/values100.txt
	average100Raw=$(cat temp/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	average100=$(printf "%.2f" $average100Raw)
	GreaterThenWithFactor $percentageGreaterFactor $last $average100; lastOverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $last $average100; lastUnderAgv100=$?

    # Averages
	GreaterThenWithFactor $percentageGreaterFactor $average18 $average38; agv18OverAgv38=$?
	LesserThenWithFactor $percentageLesserFactor $average18 $average38; agv18UnderAgv38=$?
	GreaterThenWithFactor $percentageGreaterFactor $average38 $average100; agv38OverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $average38 $average100; agv38UnderAgv100=$?
	GreaterThenWithFactor $percentageGreaterFactor $average18 $average100; agv18OverAgv100=$?
	LesserThenWithFactor $percentageLesserFactor $average18 $average100; agv18UnderAgv100=$?
 
    ProgressBar 3 8

	# Calculate RSI 14 values
	RSIInDays14=14
	RSIQuoteList=""
	RSIOfDays $RSIInDays14 $DATA_FILE

	ProgressBar 4 8

    # Calculate Stochastic 14 values
	stochasticInDays14=14
	stochasticQuoteList=""
	StochasticOfDays $stochasticInDays14 $DATA_FILE

    ProgressBar 5 8

	# Stochastics percentage
	stochasticPercentageLower=$stochasticPercentageParam
	stochasticPercentageUpper=$(echo "$stochasticPercentageLower" | awk '{print (100 - $1)}')

	# Average 18
	averageInDays18=18
	averagePriceList=""
	AverageOfDays $averageInDays18 $DATA_FILE
	averagePriceList18=$averagePriceList

	ProgressBar 6 8

    # Average 38
	averageInDays38=38
	averagePriceList=""
	AverageOfDays $averageInDays38 $DATA_FILE
	averagePriceList38=$averagePriceList

	ProgressBar 7 8

    # Average 100
	averageInDays100=100
	averagePriceList=""
	AverageOfDays $averageInDays100 $DATA_FILE
	averagePriceList100=$averagePriceList

    ProgressBar 8 8

	if [ ! $(uname) = 'Linux' ]; then
		echo ""
	fi
	
	#
	# Apply strategies
	#

	# Valid data is more then 200kb. Oherwise data might be damaged or unsufficiant
	fileSize=$(stat -c %s $DATA_FILE)
	if [ "$fileSize" -gt 200 ]; then

		# -Strategie: UnderratedByPercentAndStochastic
		resultStrategieUnderratedByPercentAndStochastic=""
		StrategieUnderratedByPercentAndStochastic
	
	    # -Strategie: Low stochastic 3 last values under lowStochasticValue
		resultStrategieUnderratedLowStochastic=""
		StrategieUnderratedLowStochastic $stochasticPercentageParam "$stochasticQuoteList"

	    # -Strategie: Low RSI last quote under lowRSIValue
		resultStrategieUnderratedLowRSI=""
		StrategieUnderratedLowRSI $RSIQuoteParam

	    # -Strategie: Low stochastic and Low RSI last quote under lowRSIValue
		resultStrategieUnderratedLowStochasticLowRSI=""
		StrategieUnderratedLowStochasticLowRSI $stochasticPercentageParam $RSIQuoteParam

		# -Strategie: The very last stochastic is lower then stochasticPercentageLower
		#resultStrategieUnderratedVeryLastStochasticIsLowerThen=""
		#StrategieUnderratedVeryLastStochasticIsLowerThen

		# +Strategie: OverratedByPercentAndStochastic
		resultStrategieOverratedByPercentAndStochastic=""
		StrategieOverratedByPercentAndStochastic $ratedParam $lastStochasticQuoteRounded $stochasticPercentageUpper $lastOverAgv18 $lastOverAgv38 $lastOverAgv100 $agv18OverAgv38 $agv38OverAgv100 $agv18OverAgv100 $last $percentageLesserFactor $average18 $average38 $average100 $lastStochasticQuoteRounded $stochasticPercentageUpper $OUT_RESULT_FILE $symbol
	else
	    echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $OUT_RESULT_FILE
		echo "<br>" >> $OUT_RESULT_FILE
	fi

	#
	# Output
	#

    # Writing chart ${symbol}.html
	commaPriceListFile=temp/commaPriceListFile.txt
	cat $DATA_FILE | tac > $commaPriceListFile
	commaPriceList=$(cat $commaPriceListFile | awk '{ print $1","; }')
    indexSymbolFile=out/${symbol}.html
	
	rm -rf $indexSymbolFile
	cp js/_chart.min.js out
	cp js/_utils.js out
	cp js/_favicon.ico out
	cat js/indexPart0.html >> $indexSymbolFile
	echo "${symbol}" >> $indexSymbolFile
	cat js/indexPart1.html >> $indexSymbolFile
	echo "'" ${symbolName} "'," >> $indexSymbolFile
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

	echo $stochasticQuoteList >> $indexSymbolFile
	cat js/indexPart10.html >> $indexSymbolFile

	echo $RSIQuoteList >> $indexSymbolFile
	cat js/indexPart11.html >> $indexSymbolFile

	ID_NOTATION=$(grep "${symbol}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
    echo "<p><a href="$COMDIRECT_URL_PREFIX$ID_NOTATION " target=_blank>$symbolName</a><br>" >> $indexSymbolFile
	echo "Percentage:<b>$percentageParam</b> " >> $indexSymbolFile
	echo "Query:<b>$queryParam</b> " >> $indexSymbolFile
	echo "Rated:<b>$ratedParam</b> " >> $indexSymbolFile
	echo "Stochastic14:<b>$stochasticPercentageParam</b> " >> $indexSymbolFile
	echo "RSI14:<b>$RSIQuoteParam</b><br>" >> $indexSymbolFile

	echo "Date:<b>"$(stat -c %y $DATA_FILE | cut -b 1-10) "</b>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(0, 0, 0);\">Last price:<b>"$last "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(153, 102, 255);\">Avg18:<b>"$average18 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(255, 99, 132);\">Avg38:<b>"$average38 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Avg100:<b>"$average100 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(255, 159, 64);\">Stoch14:<b>"$lastStochasticQuoteRounded "</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(54, 162, 235);\">RSI14:<b>"$lastRSIQuoteRounded "</b></span></p>" >> $indexSymbolFile

	# Strategies output
	# +
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieOverratedByPercentAndStochastic "</b></p>" >> $indexSymbolFile
	# -
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedByPercentAndStochastic "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedLowStochastic "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(54, 162, 235);\"><b>" $resultStrategieUnderratedLowRSI "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(54, 162, 235);\"><b>" $resultStrategieUnderratedLowStochasticLowRSI "</b></p>" >> $indexSymbolFile
	#echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedVeryLastStochasticIsLowerThen "</b></p>" >> $indexSymbolFile
	echo "Good Luck!" >> $indexSymbolFile

	cat js/indexPart12.html >> $indexSymbolFile
done

echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE

# Write temp/*.html symbolFile's for later screenshot in github workflow!
rm -rf temp/*.html
i=1
for symbolFile in $reportedSymbolFileList
do
	#echo symbolFile $symbolFile
	cp $symbolFile temp/$i.html
	i=$(( i + 1 ))
done
# Maximal 5 hardcoded screenshot. If this value is increased, then increase it in github workflow as well! (swinton/screenshot-website)
while [ "$i" -le 5 ];
do
	touch temp/$i.html
	i=$(( i + 1 ))
done

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Cleanup
rm -rf $commaPriceListFile
rm -rf $stochasticFile
rm temp/values*.txt
reportedSymbolFileList=$(echo $reportedSymbolFileList $OUT_RESULT_FILE)
tar -zcf $OUT_ZIP_FILE $reportedSymbolFileList
mv $OUT_ZIP_FILE out
