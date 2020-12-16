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
indexSymbolFileList=$OUT_RESULT_FILE
TICKER_NAMES_FILE=data/_ticker_names.txt
# Email header
HTML_RESULT_FILE_HEADER=$(echo "<html><head><link rel=\"shortcut icon\" type=\"image/ico\" href=\"_favicon.ico\" /><title>Result</title><style>.colored {color: blue;}#body {font-size: 14px;}@media screen and (min-width: 500px)</style></head><body><div><p>Stock Analyse,</p><p>")
echo $HTML_RESULT_FILE_HEADER > $OUT_RESULT_FILE
HTML_RESULT_FILE_END=$(echo "</p><p>Thanks</p></div></body></html>" )
COMDIRECT_URL_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?NAME_PORTFOLIO=Watch&POSITION=234%2C%2C24125490&timeSpan=1Y&chartType=MOUNTAIN&interactivequotes=true&disbursement_split=false&news=false&rel=false&log=false&useFixAverage=false&freeAverage0=100&freeAverage1=38&freeAverage2=18&expo=false&fundWithEarnings=true&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1&ID_NOTATION="
START_TIME_MEASUREMENT=$(date +%s);

# Check for duplicate symbol in cmd
echo $symbolsParam | tr " " "\n" | sort | uniq -c | grep -qv '^ *1 ' && echo $symbolsParam | tr " " "\n" | sort | uniq -c && echo "Duplicate symbol in parameter list!" | tee -a $OUT_RESULT_FILE && echo "<br>" >> $OUT_RESULT_FILE && exit

# Check parameter
if  [ ! -z "${symbolsParam##*[!A-Z0-9. ]*}" ] &&
	[ ! -z "${percentageParam##*[!0-9]*}" ]  && 
	( [ "$queryParam" = 'offline' ] || [ "$queryParam" = 'online' ] ) &&
	( [ "$ratedParam" = 'overrated' ] || [ "$ratedParam" = 'underrated' ] ) &&
	[ ! -z "${stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#stochasticPercentageParam} -gt 1 ] &&
	[ ! -z "${RSIQuoteParam##*[!0-9]*}" ]; then
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
	echo " STOCHASTIC14: Percentage for stochastic indicator (only single digit allowed!)" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
	echo " RSI14: Quote for RSI indicator" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE	
	echo "Example: ./analyse.sh 'ADS ALV' 3 offline underrated 9 30" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
    echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE
	exit
fi

if [ -z "$MARKET_STACK_ACCESS_KEY" ] || [ -z "$MARKET_STACK_ACCESS_KEY2" ]; then
	echo "Error: MARKET_STACK_ACCESS_KEY or MARKET_STACK_ACCESS_KEY2 not set!" | tee -a $OUT_RESULT_FILE
	echo "<br>" >> $OUT_RESULT_FILE
    echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE
	exit
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

echo "# Analyse parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$(( countSymbols + 1 ))
echo "Symbols ($countSymbols): $symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage: $percentageParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Query: $queryParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Rated: $ratedParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic14: $stochasticPercentageParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI14: $RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "<br><br># Result<br>" >> $OUT_RESULT_FILE
echo "<a href="https://github.com/Hefezopf/stock-analyse/actions" target=_blank>Github Action</a><br><br>" >> $OUT_RESULT_FILE
echo "# URLs<br>" >> $OUT_RESULT_FILE

# Analyse data for each symbol
for symbol in $symbolsParam
do
	# Get symbol names
	symbol=$(echo ${symbol} | tr a-z A-Z)
	symbolName=$(grep -w "$symbol " $TICKER_NAMES_FILE)
	if [ ! "${#symbolName}" -gt 1 ]; then
    	symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${symbol}'"}]' | jq '.[0].data[0].name')
		if ! [ "$symbolName" = 'null' ]; then
			echo $symbol $symbolName | tee -a $TICKER_NAMES_FILE
			# Can requested in bulk request as an option!
			sleep 13 # only some requests per minute to openfigi (About 6 per minute).
		fi
	fi	

	# Get stock data
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
			echo "!Symbol NOT found online in marketstack.com: $symbol" | tee -a $OUT_RESULT_FILE
			echo "<br>" >> $OUT_RESULT_FILE
			rm -rf $DATA_FILE
			exit
		fi
	fi

    echo " "
	symbolName=$(grep -w "$symbol " $TICKER_NAMES_FILE)
	#echo "# Analyse " $symbolName
	CreateCmdAnalyseHyperlink

	ProgressBar 1 8

    DATA_FILE=data/${symbol}.txt
	lastRaw=$(head -n1 -q $DATA_FILE)
	last=$(printf "%.2f\n" $lastRaw)
    #last=$lastRaw

	# Check for unknown symbol in cmd; No stock data could be fetched earlier
	if [ "${#lastRaw}" -eq 0 ]; then
		echo "!Symbol NOT found offline in data/*.txt.: $symbol. Try online query!" | tee -a $OUT_RESULT_FILE
		echo "<br>" >> $OUT_RESULT_FILE
		exit
	fi

	head -n18 $DATA_FILE > temp/values18.txt
	average18Raw=$(cat temp/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	average18=$(printf "%.2f\n" $average18Raw)

    ProgressBar 2 8

	GreaterThenWithFactor $percentageGreaterFactor $last $average18; lastOverAgv18=$?
	LesserThenWithFactor $percentageLesserFactor $last $average18; lastUnderAgv18=$?

	head -n38 $DATA_FILE > temp/values38.txt
	average38Raw=$(cat temp/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	average38=$(printf "%.2f\n" $average38Raw)
	GreaterThenWithFactor $percentageGreaterFactor $last $average38; lastOverAgv38=$?
    LesserThenWithFactor $percentageLesserFactor $last $average38;lastUnderAgv38=$?
	
	head -n100 $DATA_FILE > temp/values100.txt
	average100Raw=$(cat temp/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	average100=$(printf "%.2f\n" $average100Raw)
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
	RSIOfDays $RSIInDays14
	RSIQuoteList14=$RSIQuoteList

	ProgressBar 4 8

    # Calculate Stochastic 14 values
	stochasticInDays14=14
	stochasticQuoteList=""
	StochasticOfDays $stochasticInDays14
	stochasticQuoteList14=$stochasticQuoteList

    ProgressBar 5 8

	# Stochastics percentage
	stochasticPercentageLower=$stochasticPercentageParam
	stochasticPercentageUpper=$(echo "$stochasticPercentageLower" | awk '{print (100 - $1)}')

	# Average 18
	averageInDays18=18
	averagePriceList=""
	AverageOfDays $averageInDays18
	averagePriceList18=$averagePriceList

	ProgressBar 6 8

    # Average 38
	averageInDays38=38
	averagePriceList=""
	AverageOfDays $averageInDays38
	averagePriceList38=$averagePriceList

	ProgressBar 7 8

    # Average 100
	averageInDays100=100
	averagePriceList=""
	AverageOfDays $averageInDays100
	averagePriceList100=$averagePriceList

    ProgressBar 8 8
	
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
		StrategieOverratedByPercentAndStochastic
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

	echo $stochasticQuoteList14 >> $indexSymbolFile
	cat js/indexPart10.html >> $indexSymbolFile

	echo $RSIQuoteList14 >> $indexSymbolFile
	cat js/indexPart11.html >> $indexSymbolFile

	ID_NOTATION=$(grep "${symbol}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
    echo "<p><a href="$COMDIRECT_URL_PREFIX$ID_NOTATION" target=_blank>$symbolName</a><br>" >> $indexSymbolFile
	echo "Percentage: $percentageParam<br>"  >> $indexSymbolFile
	echo "Query: $queryParam<br>"  >> $indexSymbolFile
	echo "Rated: $ratedParam<br>"  >> $indexSymbolFile
	echo "Stochastic14: $stochasticPercentageParam<br>"  >> $indexSymbolFile
	echo "RSI14: $RSIQuoteParam<br>"  >> $indexSymbolFile
	echo "Date:<b>" $(stat -c %y $DATA_FILE | cut -b 1-10) "</b>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(0, 0, 0);\">Final price:<b>" $last "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(153, 102, 255);\">Avg18:<b>" $average18 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(255, 99, 132);\">Avg38:<b>" $average38 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Avg100:<b>" $average100 "&#8364;</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(255, 159, 64);\">Stoch14:<b>" $lastStochasticQuoteRounded "</b></span>" >> $indexSymbolFile
	echo "&nbsp;<span style=\"color:rgb(54, 162, 235);\">RSI14:<b>" $lastRSIQuoteRounded "</b></span></p>" >> $indexSymbolFile

	# Strategies output
	# +
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieOverratedByPercentAndStochastic "</b></p>" >> $indexSymbolFile
	# -
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedByPercentAndStochastic "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedLowStochastic "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(54, 162, 235);\"><b>" $resultStrategieUnderratedLowRSI "</b></p>" >> $indexSymbolFile
	echo "<p style=\"color:rgb(54, 162, 235);\"><b>" $resultStrategieUnderratedLowStochasticLowRSI "</b></p>" >> $indexSymbolFile
	#echo "<p style=\"color:rgb(255, 159, 64);\"><b>" $resultStrategieUnderratedVeryLastStochasticIsLowerThen "</b></p>" >> $indexSymbolFile
	echo "<p>Good Luck!</p>" >> $indexSymbolFile

	cat js/indexPart12.html >> $indexSymbolFile
done

echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo " "
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Cleanup
rm $commaPriceListFile
rm $stochasticFile
rm temp/values*.txt
tar -zcf $OUT_ZIP_FILE $indexSymbolFileList
mv $OUT_ZIP_FILE out
