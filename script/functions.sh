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
# Input is amountOfDaysParam($1)
# Output: averagePriceList is comma separted list
AverageOfDays() {
	amountOfDaysParam=${1}
	i=1
	while [ "$i" -lt "${1}" ]; do # Fill with blank comma seperated data
		averagePriceList=$(echo $averagePriceList ",")
		i=$(( i + 1 ))
	done 

	i=0
	while [ "$i" -le $((100-amountOfDaysParam)) ]; 
	do
		headLines=$(echo $((100-$i)))
	    averagePrice=$(head -n$headLines $DATA_FILE | tail -"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
}

# RSIOfDays function:
# Input is amountOfDaysParam($1)
# Output: RSIQuoteList is comma separted list
RSIOfDays() {
	amountOfDaysParam=${1}
	RSIwinningDaysFile=temp/RSI_WinningDays.txt
	RSIloosingDaysFile=temp/RSI_LoosingDays.txt
	rm -rf $RSIwinningDaysFile
	rm -rf $RSIloosingDaysFile
	i=1
	while [ "$i" -le 100 ];
	do
	    i=$(( i + 1 ))
		diffLast2Prices=$(head -n$i $DATA_FILE | tail -2 | awk 'p{print p-$0}{p=$0}' )
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

			RoundNumber ${RSIQuote} 0; lastRSIQuoteRounded=$?	
			RSIQuoteList=$(echo $RSIQuoteList $lastRSIQuoteRounded",")			
		fi
	done
	rm -rf $RSIwinningDaysFile
	rm -rf $RSIloosingDaysFile
}

# StochasticOfDays function:
# Input is amountOfDaysParam($1)
# Output: stochasticQuoteList is comma separted list
StochasticOfDays() {
	amountOfDaysParam=${1}
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
		head -n$headLines $DATA_FILE | tail -"${amountOfDaysParam}" > $stochasticFile
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

# CreateCmdAnalyseHyperlink function:
# - Write file Hyperlink in CMD
CreateCmdAnalyseHyperlink() {
	driveLetter=$(pwd | cut -f 2 -d '/')
	suffixPath=$(pwd | cut -b 3-200)
	verzeichnis=$driveLetter":"$suffixPath
	echo -e "\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a# Analyse "$symbol"\e]8;;\a"
	#echo -e "\e[4m\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a# Analyse "$symbol"\e]8\e[0m\a"
}