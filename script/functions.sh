# LesserThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
# Output: 1 if lesser
LesserThenWithFactor() {
    local _lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if [ awk 'BEGIN {exit !('$_lesserValue' < '$3')}' ]; then
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
	local _greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if [ awk 'BEGIN {exit !('$_greaterValue' > '$3')}' ]; then
		return 1
	else
		return 0
	fi
}

# AverageOfDays function:
# Input is amountOfDaysParam($1), dataFileParam($2)
# Output: averagePriceList is comma separted list
AverageOfDays() {
	local amountOfDaysParam=${1}
	local dataFileParam=${2}
	local i=1
	while [ "$i" -lt "${1}" ]; do # Fill with blank comma seperated data
		averagePriceList=$(echo $averagePriceList ",")
		i=$(( i + 1 ))
	done 

	local i=0
	while [ "$i" -le $((100-amountOfDaysParam)) ]; 
	do
		local headLines=$(echo $((100-$i)))
		
	    local averagePrice=$(head -n$headLines $dataFileParam | tail -"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
		#local averagePrice=$(head -n$headLines $DATA_FILE | tail -"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
		averagePriceList=$(echo $averagePriceList $averagePrice",")
		i=$(( i + 1 ))
	done
	averagePriceList=$averagePriceList
}

# RSIOfDays function:
# Input is amountOfDaysParam($1), dataFileParam($2)
# Output: RSIQuoteList is comma separted list
RSIOfDays() {
	local amountOfDaysParam=${1}
	local dataFileParam=${2}
	local RSIwinningDaysFile=temp/RSI_WinningDays.txt
	local RSIloosingDaysFile=temp/RSI_LoosingDays.txt
	rm -rf $RSIwinningDaysFile
	rm -rf $RSIloosingDaysFile
	local i=1
	while [ "$i" -le 100 ];
	do
	    i=$(( i + 1 ))
		local diffLast2Prices=$(head -n$i $dataFileParam | tail -2 | awk 'p{print p-$0}{p=$0}' )
		local isNegativ=$(echo "${diffLast2Prices}" | awk '{print substr ($0, 0, 1)}')
		if [ ! ${isNegativ} = '-' ]; then
			echo $diffLast2Prices >> $RSIwinningDaysFile
		else
			echo 0 >> $RSIwinningDaysFile
		fi

		if [ ${isNegativ} = '-' ]; then
		    local withoutMinusSign=$(echo "${diffLast2Prices}" | awk '{print substr ($1, 2, 9)}')
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
	        local RSIwinningDaysAvg=$(tail -"${i}" $RSIwinningDaysFile | head -n"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }')
			local RSIloosingDaysAvg=$(tail -"${i}" $RSIloosingDaysFile | head -n"${amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'${amountOfDaysParam}'; }') 
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
	local amountOfDaysParam=${1}
	local dataFileParam=${2}
	local stochasticFile=temp/stochastic.txt
	local i=1
	# Fill with blank comma seperated data
	while [ "$i" -lt "${1}" ]; do 
		stochasticQuoteList=$(echo $stochasticQuoteList ",")
		i=$(( i + 1 ))
	done 

	i=0
	# TODO optimize not 100 loop?!
	while [ "$i" -le $((100-amountOfDaysParam)) ];
	do
		local headLines=$(echo $((100-$i)))
		head -n$headLines $dataFileParam | tail -"${amountOfDaysParam}" > $stochasticFile
		local lastStochasticRaw=$(head -n 1 $stochasticFile)
		local lowestStochasticRaw=$(sort -g $stochasticFile | head -n 1)
		local highestStochasticRaw=$(sort -gr $stochasticFile | head -n 1)

		if [ awk 'BEGIN {exit !('$highestStochasticRaw' > '$lowestStochasticRaw')}' ]; then
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

	#echo stochasticQuoteList $stochasticQuoteList
	stochasticQuoteList=$stochasticQuoteList
	#exit
}

# ProgressBar function:
# Input is currentStateParam($1) and totalStateParam($2)
# Output: echo
ProgressBar() {
	local currentStateParam=${1}
	local totalStateParam=${2}
	local _progress_=$(echo $((currentStateParam*100/totalStateParam*100)))
	local _progress=$(echo $(($_progress_/100)))
	local _done_=$(echo $((${_progress}*4)))
	local _done=$(echo $(($_done_/10)))
    local _left=$(echo $((40-$_done)))
	# Build progressbar string lengths
	local _fill=$(printf "%${_done}s")
	local _empty=$(printf "%${_left}s")                         
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
	local ID_NOTATION=$(grep "${symbol}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
	if [ ! "${#ID_NOTATION}" -gt 1 ]; then
		ID_NOTATION=999999
	fi
	# only write URL once into result file
	if [ ! "${ID_NOTATION}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
		local ID_NOTATION_STORE_FOR_NEXT_TIME=$ID_NOTATION
		echo "<a href="$COMDIRECT_URL_PREFIX$ID_NOTATION " target=_blank>$symbolName</a><br>" >> $OUT_RESULT_FILE
		# Store list of files for later (tar/zip)
	    reportedSymbolFileList=$(echo $reportedSymbolFileList out/${symbol}.html)
	fi
	reportedSymbolFileList=$reportedSymbolFileList
}

# CreateCmdAnalyseHyperlink function:
# - Write file Hyperlink in CMD
CreateCmdAnalyseHyperlink() {
	local outputText="# Analyse "$symbolName
	if [ $(uname) = 'Linux' ]; then
		echo $outputText
	else
		local driveLetter=$(pwd | cut -f 2 -d '/')
		local suffixPath=$(pwd | cut -b 3-200)
		local verzeichnis=$driveLetter":"$suffixPath
		echo -e "\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a$outputText\e]8;;\a"
		#echo -e "\e[4m\e]8;;file:///"$verzeichnis"/out/"$symbol".html\a$outputText\e]8\e[0m\a"
	fi
}