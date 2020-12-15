
# StrategieOverratedByPercentAndStochastic function:
# Strategie: Overrated by Percent and Stochastic
# Input -
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {	
    if [ "$ratedParam" = 'overrated' ]; then
        if [ "$lastStochasticQuoteRounded" -gt "$stochasticPercentageUpper" ] && [ "$lastOverAgv18" = 1 ] && [ "$lastOverAgv38" = 1 ] && [ "$lastOverAgv100" = 1 ] && 
            [ "$agv18OverAgv38" = 1 ] && [ "$agv38OverAgv100" = 1 ] && [ "$agv18OverAgv100" = 1 ]; then
            resultStrategieOverratedByPercentAndStochastic="- Overrated by percent and stochastic: $last EUR is $percentageLesserFactor over Avg18: $average18 EUR and Avg38: $average38 EUR and Avg100: $average100 EUR and Stoc14 is $lastStochasticQuoteRounded is higher then $stochasticPercentageUpper"
            echo $resultStrategieOverratedByPercentAndStochastic
            WriteComdirectUrlAndStoreFileList
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
            resultStrategieUnderratedByPercentAndStochastic="+ Underrated by percent and stochastic: $last EUR is $percentageGreaterFactor under Avg18: $average18 EUR and Avg38: $average38 EUR and Avg100: $average100 EUR and Stoch14 $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
            echo $resultStrategieUnderratedByPercentAndStochastic
            WriteComdirectUrlAndStoreFileList
        fi
    fi
}

# StrategieUnderratedVeryLastStochasticIsLowerThen function:
# Strategie: The very last stochastic is lower then stochasticPercentageLower
# Input is lastStochasticQuoteRounded($1), stochasticPercentageLower($2)
# Output: resultStrategieUnderratedVeryLastStochasticIsLowerThen
StrategieUnderratedVeryLastStochasticIsLowerThen() {
    if [ "$ratedParam" = 'underrated' ]; then	
        if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ]; then
            resultStrategieUnderratedVeryLastStochasticIsLowerThen="+ Very last stochastic: last stochastic quote $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
            echo $resultStrategieUnderratedVeryLastStochasticIsLowerThen
            WriteComdirectUrlAndStoreFileList
        fi
    fi
}

# StrategieUnderratedLowStochastic function:
# Strategie: Low stochastic 3 last values under lowStochasticValue
# Input is lowStochasticValue($1), stochasticQuoteList($2)
# Output: resultStrategieUnderratedLowStochastic
StrategieUnderratedLowStochastic() {	
    if [ "$ratedParam" = 'underrated' ]; then	
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
        resultStrategieUnderratedLowStochastic=""
        # All 3 last values under _lowStochasticValue?
        if [ "$howManyUnderLowStochasticValue" -gt 2 ]; then
            resultStrategieUnderratedLowStochastic="+ Low stochastic: 3 last stochastic quotes are under: $_lowStochasticValue"
            echo $resultStrategieUnderratedLowStochastic
            WriteComdirectUrlAndStoreFileList
        fi
    fi
}

# StrategieUnderratedLowRSI function:
# Strategie: Low RSI last quote under lowRSIValue
# https://www.charttec.de/html/indikator_rsi_relative_strength_index.php
# https://de.wikipedia.org/wiki/Relative_Strength_Index
# Input is lowRSIValue($1)
# Output: resultStrategieUnderratedLowRSI
StrategieUnderratedLowRSI() {	
    if [ "$ratedParam" = 'underrated' ]; then	
        _lowRSIValue="$1"
        #_RSIQuoteList="$2"
        #RSIlastQuote=$(echo "$_RSIQuoteList" | cut -f 100 -d ',')
        resultStrategieUnderratedLowRSI=""
        # Last RSI quote under _lowRSIValue
        if [ "$lastRSIQuoteRounded" -lt $_lowRSIValue ]; then
            resultStrategieUnderratedLowRSI="+ Low RSI: last RSI quote $lastRSIQuoteRounded under: $_lowRSIValue"
            echo $resultStrategieUnderratedLowRSI
            WriteComdirectUrlAndStoreFileList
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSI function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue
# Input is lowStochasticValue($1), lowRSIQuoteParam($2)
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSI() {	
    if [ "$ratedParam" = 'underrated' ]; then	
        _lowStochasticValue="$1"
        #_stochasticQuoteList="$2"
        _lowRSIQuoteParam="$2"
        #_RSIQuoteList="$4"   
        #stochasticLastQuote=$(echo "$_stochasticQuoteList" | cut -f 100 -d ',')
        #RSIlastQuote=$(echo "$_RSIQuoteList" | cut -f 100 -d ',')
        #lastRSIQuoteRounded #lastRSIQuoteRounded
        resultStrategieUnderratedLowStochasticLowRSI=""
        # Last Stoch quote under _lowStochasticValue and Last RSI quote under _lowRSIValue
        if [ "$lastRSIQuoteRounded" -lt $_lowStochasticValue ] && [ "$lastRSIQuoteRounded" -lt $_lowRSIQuoteParam ]; then
            resultStrategieUnderratedLowStochasticLowRSI="+ Low Stoch & Low RSI: last Stoch quote $lastRSIQuoteRounded under: $_lowStochasticValue and last RSI quote $lastRSIQuoteRounded under: $_lowRSIQuoteParam"
            echo $resultStrategieUnderratedLowStochasticLowRSI
            WriteComdirectUrlAndStoreFileList
        fi
    fi
}
