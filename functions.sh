# LesserThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
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
		head -n$headLines data/values.${symbol}.txt | tail -"${1}" > $stochasticFile
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
