# CurlSymbolName function:
# Input is _symbolParam($1), _TICKER_NAMES_FILE_param($2), _sleepParam($3)
# Output: TICKER_NAMES_FILE
CurlSymbolName() {
	_symbolParam=${1}
	_TICKER_NAMES_FILE_param=${2}
	_sleepParam=${3}
	symbol=$(echo ${_symbolParam} | tr a-z A-Z)
	symbolName=$(grep -w "$_symbolParam " $_TICKER_NAMES_FILE_param)
	if [ ! "${#symbolName}" -gt 1 ]; then
    	symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${_symbolParam}'"}]' | jq '.[0].data[0].name')
		if ! [ "$symbolName" = 'null' ]; then
			echo $symbol $symbolName | tee -a $_TICKER_NAMES_FILE_param
			# Can requested in bulk request as an option!
			sleep $_sleepParam # 14; Only some requests per minute to openfigi (About 6 per minute).
		fi
	fi		
	symbolName=$symbolName
}	

# UsageCheckParameter function:
# Input is _symbolsParam($1), _percentageParam($2), _queryParam($3), _ratedParam($4), _stochasticPercentageParam($5), _RSIQuoteParam($6), OUT_RESULT_FILE_param($7)
# Output: OUT_RESULT_FILE
UsageCheckParameter() {
    _symbolsParam=${1}
	_percentageParam=${2}
	_queryParam=${3}
	_ratedParam=${4}
	_stochasticPercentageParam=${5}
	_RSIQuoteParam=${6}
	OUT_RESULT_FILE_param=${7}
	if  [ ! -z "${_symbolsParam##*[!a-zA-Z0-9 ]*}" ] &&
		[ ! -z "${_percentageParam##*[!0-9]*}" ]  && 
		( [ "$_queryParam" = 'offline' ] || [ "$_queryParam" = 'online' ] ) &&
		( [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'underrated' ] ) &&
		[ ! -z "${_stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#_stochasticPercentageParam} -gt 1 ] &&
		[ ! -z "${_RSIQuoteParam##*[!0-9]*}" ]; then
		echo ""
	else
		echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " PERCENTAGE: Percentage number between 0..100" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " QUERY: Query data online|offline" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " RATED: List only overrated|underrated" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " STOCHASTIC14: Percentage for stochastic indicator (only single digit allowed!)" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo " RSI14: Quote for RSI indicator" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param	
		echo "Example: ./analyse.sh 'ADS ALV' 3 offline underrated 9 30" | tee -a $OUT_RESULT_FILE_param
		echo "<br>" >> $OUT_RESULT_FILE_param
		echo $HTML_RESULT_FILE_END >> $OUT_RESULT_FILE_param
		exit 5
	fi
}

# LesserThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
# Output: 1 if lesser
LesserThenWithFactor() {
    _lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$_lesserValue' < '$3')}'; then
		return 1
	else
		return 0		
	fi
}

# GreaterThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
# Output: 1 if 'factor'*'firstCompareValue'>'secondCompareValue' else 0
# Example 1.1*100>109 -> return 1
# Example 1.1*100>110 -> return 0
GreaterThenWithFactor() {
	_greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$_greaterValue' > '$3')}'; then
		return 1
	else
		return 0
	fi
}

# AverageOfDays function:
# Input is amountOfDaysParam($1), dataFileParam($2)
# Output: averagePriceList is comma separted list
AverageOfDays() {
	amountOfDaysParam=${1}
	dataFileParam=${2}
	i=1
	while [ "$i" -lt "${1}" ]; do # Fill with blank comma seperated data
		averagePriceList=$(echo $averagePriceList ",")
		i=$(( i + 1 ))
	done 

	i=0
	while [ "$i" -le $((100-amountOfDaysParam)) ]; 
	do
		headLines=$(echo $((100-$i)))
	    averagePrice=$(head -n$headLines $dataFileParam | tail -"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
	averagePriceList=$averagePriceList
}

# RSIOfDays function:
# Input is amountOfDaysParam($1), dataFileParam($2)
# Output: RSIQuoteList is comma separted list
RSIOfDays() {
	amountOfDaysParam=${1}
	dataFileParam=${2}
	RSIwinningDaysFile=temp/RSI_WinningDays.txt
	RSIloosingDaysFile=temp/RSI_LoosingDays.txt
	rm -rf $RSIwinningDaysFile
	rm -rf $RSIloosingDaysFile
	i=1
	while [ "$i" -le 100 ];
	do
	    i=$(( i + 1 ))
		diffLast2Prices=$(head -n$i $dataFileParam | tail -2 | awk 'p{print p-$0}{p=$0}' )
		isNegativ=$(echo "${diffLast2Prices}" | awk '{print substr ($0, 0, 1)}')
		if [ ! ${isNegativ} = '-' ]; then
			echo $diffLast2Prices >> $RSIwinningDaysFile
		else
			echo 0 >> $RSIwinningDaysFile
		fi

		if [ ${isNegativ} = '-' ]; then
		    withoutMinusSign=$(echo "${diffLast2Prices}" | awk '{print substr ($1, 2, 9)}')
			echo $withoutMinusSign >> $RSIloosingDaysFile
		else
			echo 0 >> $RSIloosingDaysFile
		fi
	done

	i=1
	while [ "$i" -le 100 ];
	do
	    i=$(( i + 1 ))
		# Fill with blank comma seperated data  
		if [ $i -lt $(( amountOfDaysParam + 1 )) ]; then # <14
			RSIQuoteList=$(echo $RSIQuoteList ",")
		else # >14
	        RSIwinningDaysAvg=$(tail -"${i}" $RSIwinningDaysFile | head -n"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
			RSIloosingDaysAvg=$(tail -"${i}" $RSIloosingDaysFile | head -n"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }') 
			if [ "${RSIloosingDaysAvg}" = 0 ]; then
				RSIQuote=100
			else
				RSIQuote=$(echo "$RSIwinningDaysAvg $RSIloosingDaysAvg" | awk '{print 100-(100/(1+($1/$2)))}')
				#RSIQuote=$(echo "$RSIwinningDaysAvg" "$RSIloosingDaysAvg" | awk '{print 100*$1/($1+$2)}')
			fi

			lastRSIQuoteRounded=$(echo "$RSIQuote" | cut -f 1 -d '.')
			RSIQuoteList=$(echo $RSIQuoteList $lastRSIQuoteRounded",")			
		fi
	done
	rm -rf $RSIwinningDaysFile
	rm -rf $RSIloosingDaysFile
	RSIQuoteList=$RSIQuoteList
}

# StochasticOfDays function:
# Input is amountOfDaysParam($1), dataFileParam($2)
# Output: stochasticQuoteList is comma separted list
StochasticOfDays() {
	amountOfDaysParam=${1}
	dataFileParam=${2}
	stochasticFile=temp/stochastic.txt
	i=1
	# Fill with blank comma seperated data
	while [ "$i" -lt "${1}" ]; do 
		stochasticQuoteList=$(echo $stochasticQuoteList ",")
		i=$(( i + 1 ))
	done 

	i=0
	# TODO optimize not 100 loop?!
	while [ "$i" -le $((100-amountOfDaysParam)) ];
	do
		headLines=$(echo $((100-$i)))
		head -n$headLines $dataFileParam | tail -"${amountOfDaysParam}" > $stochasticFile
		lastStochasticRaw=$(head -n 1 $stochasticFile)
		lowestStochasticRaw=$(sort -g $stochasticFile | head -n 1)
		highestStochasticRaw=$(sort -gr $stochasticFile | head -n 1)

		if awk 'BEGIN {exit !('$highestStochasticRaw' > '$lowestStochasticRaw')}'; then
			validStochastic=1
		else 
			validStochastic=0 
		fi
		#GreaterThenWithFactor 1 $highestStochasticRaw $lowestStochasticRaw; validStochastic=$?
		if [ "$validStochastic" = 1 ]; then
			# Formula=((C – Ln )/( Hn – Ln )) * 100
			lastStochasticQuote=$(echo "$lastStochasticRaw $lowestStochasticRaw $highestStochasticRaw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
		else
			lastStochasticQuote=100
		fi

		lastStochasticQuoteRounded=$(echo "$lastStochasticQuote" | cut -f 1 -d '.')
		stochasticQuoteList=$(echo $stochasticQuoteList $lastStochasticQuoteRounded",")
		i=$(( i + 1 ))
	done
    rm -rf $stochasticFile
	stochasticQuoteList=$stochasticQuoteList
}

# ProgressBar function:
# Input is currentStateParam($1) and totalStateParam($2)
# Output: echo
ProgressBar() {
	currentStateParam=${1}
	totalStateParam=${2}
	_progress_=$(echo $((currentStateParam*100/totalStateParam*100)))
	_progress=$(echo $(($_progress_/100)))
	_done_=$(echo $((${_progress}*4)))
	_done=$(echo $(($_done_/10)))
    _left=$(echo $((40-$_done)))
	# Build progressbar string lengths
	_fill=$(printf "%${_done}s")
	_empty=$(printf "%${_left}s")                         
	# Progress: ######################################## 100%
	#if [[ $(uname) == *"MINGW"* ]]; then
	#	echo -n $(printf "\r${_fill// /#}${_empty// /-} ${_progress}%%")
	#fi
}

# WriteComdirectUrlAndStoreFileList function:
# - Write Comdirect Url.
# - Store list of files for later (tar/zip)
# Input OUT_RESULT_FILE_param($1), symbolParam($2), 
# Output: echo to file
WriteComdirectUrlAndStoreFileList() {
	OUT_RESULT_FILE_param=${1}
	symbolParam=${2}
	ID_NOTATION=$(grep "${symbolParam}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
	if [ ! "${#ID_NOTATION}" -gt 1 ]; then
		ID_NOTATION=999999
	fi
	# Only write URL once into result file
	if [ ! "${ID_NOTATION}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
		ID_NOTATION_STORE_FOR_NEXT_TIME=$ID_NOTATION
		echo "<a href="$COMDIRECT_URL_PREFIX$ID_NOTATION " target=_blank>$symbolName</a><br>" >> $OUT_RESULT_FILE_param
		# Store list of files for later (tar/zip)
	    reportedSymbolFileList=$(echo $reportedSymbolFileList out/${symbolParam}.html)
	fi
	reportedSymbolFileList=$reportedSymbolFileList
}

# CreateCmdAnalyseHyperlink function:
# - Write file Hyperlink in CMD
CreateCmdAnalyseHyperlink() {
	outputText="# Analyse "$symbolName
	if [ $(uname) = 'Linux' ]; then
		echo $outputText
	else
		driveLetter=$(pwd | cut -f 2 -d '/')
		suffixPath=$(pwd | cut -b 3-200)
		verzeichnis=$driveLetter":"$suffixPath
		echo -e "\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a$outputText\e]8;;\a"
		#echo -e "\e[4m\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a$outputText\e]8\e[0m\a"
	fi
}
