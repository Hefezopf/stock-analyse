
# StrategieOverratedByPercentAndStochastic function:
# Strategie: Overrated by Percent and Stochastic
# Input -
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {	
    if [ "$ratedParam" = 'overrated' ]; then
        if [ "$lastStochasticQuoteRounded" -gt "$stochasticPercentageUpper" ] && [ "$lastOverAgv18" = 1 ] && [ "$lastOverAgv38" = 1 ] && [ "$lastOverAgv100" = 1 ] && 
            [ "$agv18OverAgv38" = 1 ] && [ "$agv38OverAgv100" = 1 ] && [ "$agv18OverAgv100" = 1 ]; then
            resultStrategieOverratedByPercentAndStochastic="- Overrated: $last EUR is more then $percentageLesserFactor over average18: $average18 EUR and average38: $average38 EUR and over average100: $average100 EUR. Stochastic14 is $lastStochasticQuoteRounded"
            echo $resultStrategieOverratedByPercentAndStochastic
        fi
    fi
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Underrated by Percent and Stochastic
# Input -
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() {	
    if [ "$ratedParam" = 'underrated' ]; then
        if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ] && [ "$lastUnderAgv18" = 1 ] && [ "$lastUnderAgv38" = 1 ] && [ "$lastUnderAgv100" = 1 ] && 
            [ "$agv18UnderAgv38" = 1 ] && [ "$agv38UnderAgv100" = 1 ] && [ "$agv18UnderAgv100" = 1 ]; then
            resultStrategieUnderratedByPercentAndStochastic="+ Underrated by percent and stochastic: Last price $last EUR is $percentageGreaterFactor under average18: $average18 EUR and under average38: $average38 EUR and under average100: $average100 EUR and Stochastic14 $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
            echo $resultStrategieUnderratedByPercentAndStochastic
            WriteComdirectUrl
        fi
    fi
}

# StrategieVeryLastStochasticIsLowerThen function:
# Strategie: The very last stochastic is lower then stochasticPercentageLower
# Input is lastStochasticQuoteRounded($1), stochasticPercentageLower($2)
# Output: resultStrategieVeryLastStochasticIsLowerThen
StrategieVeryLastStochasticIsLowerThen() {	
    if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ]; then
        resultStrategieVeryLastStochasticIsLowerThen="+ Very last stochastic: last stochastic quote $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
        echo $resultStrategieVeryLastStochasticIsLowerThen
        WriteComdirectUrl
    fi
}

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
