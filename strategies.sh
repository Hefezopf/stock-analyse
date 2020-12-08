# StrategieLowStochastic function:
# Strategie: Low stochastic 3 last values under lowStochasticValue
# Input is lowStochasticValue($1), stochasticQuoteList($2)
# Output: resultStrategieLowStochastic
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
        resultStrategieLowStochastic="+ Low stochastic: 3 last stochastic quotes are under: $_lowStochasticValue"
        echo $resultStrategieLowStochastic
        WriteComdirectUrl
    fi
}

# RandomId function:
# Input -
# Output: -
RandomId() {	
    randomResult=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
    echo $randomResult	
}
