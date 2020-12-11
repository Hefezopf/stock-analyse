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
# Output: 1 if greater
GreaterThenWithFactor() {
	_greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('$_greaterValue' > '$3')}'; then
		return 1
	else
		return 0
	fi
}

# RoundNumber function:
# Input is floatNumber($1), digitsAfterComma($2)
# Output: Number
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
	    averagePrice=$(head -n$headLines data/${symbol}.txt | tail -"${1}" | awk '{ sum += $1; } END { print sum/'${1}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
}

# RSIOfDays function:
# Input is amountOfDays($1)
# Output: RSIQuoteList is comma separted list
RSIOfDays() {
	RSIQuoteList=""
	RSILast2PricesFile=out/RSI_Last2Prices.txt
	RSIwinningDaysFile=out/RSI_WinningDays.txt
	RSIloosingDaysFile=out/RSI_LoosingDays.txt
	RSIWinningLoosingQuotientFile=out/RSI_WinningLoosingQuotient.txt
	i=1
	# Fill with blank comma seperated data
	while [ "$i" -lt "${1}" ]; do 
		RSIQuoteList=$(echo $RSIQuoteList ",")
		i=$(( i + 1 ))
	done 

	i=1
	while [ "$i" -le 100 ];
	do
		head -n$i data/${symbol}.txt | tail -2 > $RSILast2PricesFile
		diff=$(awk 'p{print $0-p}{p=$0}' $RSILast2PricesFile)
		short="${diff:0:1}";
		if [ "$short" = '-' ]; then
			echo $diff >> $RSIloosingDaysFile
		else
		    echo $diff >> $RSIwinningDaysFile
		fi

		if [ $i -gt 14 ]; then
			headLines=$(echo $((100-$i)))
	        RSIwinningDaysAvg=$(head -n$headLines $RSIwinningDaysFile | tail -"${1}" | awk '{ sum += $1; } END { print sum/'${1}'; }')
	        RSIloosingDaysAvg=$(head -n$headLines $RSIloosingDaysFile  | tail -"${1}" | awk '{ sum += $1; } END { print sum/'${1}'; }') 
			echo $RSIwinningDaysAvg > $RSIWinningLoosingQuotientFile
			#echo $RSIloosingDaysAvg >> $RSIWinningLoosingQuotientFile
			#rech=$(echo $(($RSIwinningDaysAvg+$RSIloosingDaysAvg)))
			RSIwinningDaysloosingDaysAvg=$(echo "$RSIwinningDaysAvg $RSIloosingDaysAvg" | awk '{print $1 + $2}')
			echo RSIwinningDaysloosingDaysAvg $RSIwinningDaysloosingDaysAvg
			echo $RSIwinningDaysloosingDaysAvg >> $RSIWinningLoosingQuotientFile
			#RSIWinningLoosingQuotient=$(awk 'p{print $0/p}{p=$0}' $RSIWinningLoosingQuotientFile)
		    RSIWinningLoosingQuotient=$(echo "$RSIwinningDaysAvg $RSIwinningDaysloosingDaysAvg" | awk '{print $1 / $2}')
		    RSIQuoteList=$(echo $RSIQuoteList $RSIWinningLoosingQuotient",")
		fi
		i=$(( i + 1 ))
	done
	#rm -rf $RSIwinningDaysFile
	#rm -rf $RSIloosingDaysFile
	#rm -rf $RSIloosingDaysFile
	#rm -rf $RSIWinningLoosingQuotientFile
}

# StochasticOfDays function:
# Input is amountOfDays($1)
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
		head -n$headLines data/${symbol}.txt | tail -"${1}" > $stochasticFile
		lastStochasticRaw=$(head -n 1 $stochasticFile)
		lowestStochasticRaw=$(sort -g $stochasticFile | head -n 1)
		highestStochasticRaw=$(sort -gr $stochasticFile | head -n 1)
		GreaterThenWithFactor 1 $highestStochasticRaw $lowestStochasticRaw; validStochastic=$?
		if [ "$validStochastic" = 1 ]; then
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

# ProgressBar function:
# Input is currentState($1) and totalState($2)
# Output: echo
ProgressBar() {
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

# WriteComdirectUrlAndStoreFileList function:
# - Write Comdirect Url.
# - Store list of files for later (tar/zip)
# Input -
# Output: echo to file
WriteComdirectUrlAndStoreFileList() {
	ID_NOTATION=$(grep "${symbolRaw}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
	if [ ! "${#ID_NOTATION}" -gt 1 ]; then
		ID_NOTATION=999999
	fi
	# only write URL once into result file
	if [ ! "${ID_NOTATION}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
		ID_NOTATION_STORE_FOR_NEXT_TIME=$ID_NOTATION
		echo "<a href="$COMDIRECT_URL_PREFIX$ID_NOTATION" target=_blank>$symbolName</a><br>" >> $OUT_RESULT_FILE
		# Store list of files for later (tar/zip)
	    indexSymbolFileList=$(echo $indexSymbolFileList out/${symbolRaw}.html)
	fi
}
