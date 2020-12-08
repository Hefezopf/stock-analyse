# StrategieLowStochastic function:
# Input is lowStochasticValue($1), stochasticQuoteList($2)
# Strategie: Low stochastic 3 last values under lowStochasticValue
StrategieLowStochastic() {		
    _lowStochasticValue="$1"
    _stochasticQuoteList="$2"
    # Revers and output the last x numbers. Attention only works for single digst numbers!
    _stochasticQuoteList=$(echo "$_stochasticQuoteList" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 }' )
    OLDIFS=$IFS
    IFS="," set -- $_stochasticQuoteList
    # Cut comma, like: ",22" -> "22"
    value1=$(echo "$1" | cut -b 2-3)
    value2=$(echo "$2" | cut -b 2-3)
    value3=$(echo "$3" | cut -b 2-3)
    IFS=$OLDIFS
    howManyUnderLowStochasticValue=0
    # Check string length and low stochastic parameter
    if [ ! "${#value1}" -gt 1 ] && [ "$value1" -lt "$_lowStochasticValue" ]; then
        howManyUnderLowStochasticValue=$(($howManyUnderLowStochasticValue + 1))
    fi
    if [ ! "${#value2}" -gt 1 ] && [ "$value2" -lt "$_lowStochasticValue" ]; then
        howManyUnderLowStochasticValue=$(($howManyUnderLowStochasticValue + 1))
    fi
    if [ ! "${#value3}" -gt 1 ] && [ "$value3" -lt "$_lowStochasticValue" ]; then
        howManyUnderLowStochasticValue=$(($howManyUnderLowStochasticValue + 1))
    fi
    resultStrategieLowStochastic=""
    # All 3 last values under _lowStochasticValue?
    if [ "$howManyUnderLowStochasticValue" -gt 2 ]; then
        resultStrategieLowStochastic="+ Low stochastic: $symbol has the last 3 quotes under: $_lowStochasticValue"
        echo $resultStrategieLowStochastic
        #echo "\"http://www.google.com/search?tbm=fin&q=${symbol}\" " >> $OUT_RESULT_FILE

        ID_NOTATION=$(grep "${symbolRaw}" data/ticker_idnotation.txt | cut -f 2 -d ' ')
        if [ ! "${#ID_NOTATION}" -gt 1 ]; then
            ID_NOTATION=999999
        fi        
        echo "https://nutzer.comdirect.de/inf/aktien/detail/chart_big.html?NAME_PORTFOLIO=Watch&POSITION=234%2C%2C24125490&timeSpan=1Y&chartType=MOUNTAIN&interactivequotes=true&disbursement_split=false&news=false&rel=false&log=false&useFixAverage=false&freeAverage0=100&freeAverage1=38&freeAverage2=18&expo=false&fundWithEarnings=true&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&indicatorsBelowChart=SST&PRESET=1&ID_NOTATION=$ID_NOTATION" >> $OUT_RESULT_FILE
    fi
}

