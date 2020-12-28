#!/bin/bash

# StrategieOverratedByPercentAndStochastic function:
# Strategie: Overrated by Percent and Stochastic
# Input: ratedParam($1)lastStochasticQuoteRounded($2), stochasticPercentageUpper($3), lastOverAgv18($4), lastOverAgv38($5), lastOverAgv100($6), agv18OverAgv38($7), agv38OverAgv100($8), agv18OverAgv100($9), last($10), percentageLesserFactor($11), average18($12), average38($13), average100($14), lastStochasticQuoteRounded($15), stochasticPercentageUpper($16), OUT_RESULT_FILE_param($17), symbolParam($18)
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {
    _ratedParam=${1}
    _lastStochasticQuoteRounded=${2}
    _stochasticPercentageUpper=${3}
    _lastOverAgv18=${4}
    _lastOverAgv38=${5}
    _lastOverAgv100=${6}
    _agv18OverAgv38=${7}
    _agv38OverAgv100=${8}
    _agv18OverAgv100=${9}
    _last=${10}
    _percentageLesserFactor=${11}
    _average18=${12}
    _average38=${13}
    _average100=${14}
    _lastStochasticQuoteRounded=${15}
    _stochasticPercentageUpper=${16}
    _OUT_RESULT_FILE_param=${17}
    _symbolParam=${18}
    if [ "$_ratedParam" = 'overrated' ]; then
        if [ "$_lastStochasticQuoteRounded" -gt "$_stochasticPercentageUpper" ] && [ "$_lastOverAgv18" = 1 ] && [ "$_lastOverAgv38" = 1 ] && [ "$_lastOverAgv100" = 1 ] && 
            [ "$_agv18OverAgv38" = 1 ] && [ "$_agv38OverAgv100" = 1 ] && [ "$_agv18OverAgv100" = 1 ]; then
            resultStrategieOverratedByPercentAndStochastic="- Overrated by percent and stochastic: $_last EUR is $_percentageLesserFactor over Avg18 $_average18 EUR and Avg38 $_average38 EUR and Avg100 $_average100 EUR and Stoc14 is $_lastStochasticQuoteRounded is higher then $_stochasticPercentageUpper"
            echo $resultStrategieOverratedByPercentAndStochastic
            WriteComdirectUrlAndStoreFileList $_OUT_RESULT_FILE_param $_symbolParam "$symbolName" true
        fi
    fi
    resultStrategieOverratedByPercentAndStochastic=$resultStrategieOverratedByPercentAndStochastic
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Underrated by Percent and Stochastic
# Input -
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() {    
    if [ "$ratedParam" = 'underrated' ]; then
        if [ "$lastStochasticQuoteRounded" -lt "$stochasticPercentageLower" ] && [ "$lastUnderAgv18" = 1 ] && [ "$lastUnderAgv38" = 1 ] && [ "$lastUnderAgv100" = 1 ] && 
            [ "$agv18UnderAgv38" = 1 ] && [ "$agv38UnderAgv100" = 1 ] && [ "$agv18UnderAgv100" = 1 ]; then
            resultStrategieUnderratedByPercentAndStochastic="+ Underrated by percent and stochastic: $last EUR is $percentageGreaterFactor under Avg18 $average18 EUR and Avg38 $average38 EUR and Avg100 $average100 EUR and Stoch14 $lastStochasticQuoteRounded is lower then $stochasticPercentageLower"
            echo $resultStrategieUnderratedByPercentAndStochastic
            WriteComdirectUrlAndStoreFileList $OUT_RESULT_FILE $symbol "$symbolName" true
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
            WriteComdirectUrlAndStoreFileList $OUT_RESULT_FILE $symbol "$symbolName" true
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
        # v1=$(echo "$1")
		# value1=${v1:1:2}
        # v2=$(echo "$2")
		# value2=${v2:1:2}
        # v3=$(echo "$3")
		# value3=${v3:1:2}   

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
            resultStrategieUnderratedLowStochastic="+ Low stochastic: 3 last stochastic quotes are under $_lowStochasticValue"
            echo $resultStrategieUnderratedLowStochastic
            WriteComdirectUrlAndStoreFileList $OUT_RESULT_FILE $symbol "$symbolName" true
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
        resultStrategieUnderratedLowRSI=""
        # Last RSI quote under _lowRSIValue
        if [ "$lastRSIQuoteRounded" -lt $_lowRSIValue ]; then
            resultStrategieUnderratedLowRSI="+ Low RSI: last RSI quote $lastRSIQuoteRounded under $_lowRSIValue"
            echo $resultStrategieUnderratedLowRSI
            WriteComdirectUrlAndStoreFileList $OUT_RESULT_FILE $symbol "$symbolName" true
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSI function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue
# Input is lowStochasticValue($1), lowRSIQuoteParam($2)
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSI() {    
    _lowStochasticValue="$1"
    _lowRSIQuoteParam="$2"
    if [ "$ratedParam" = 'underrated' ]; then    
        resultStrategieUnderratedLowStochasticLowRSI=""
        # Last Stoch quote under _lowStochasticValue and Last RSI quote under _lowRSIValue
        if [ "$lastRSIQuoteRounded" -lt $_lowStochasticValue ] && [ "$lastRSIQuoteRounded" -lt $_lowRSIQuoteParam ]; then
            resultStrategieUnderratedLowStochasticLowRSI="+ Low Stoch & Low RSI: last Stoch quote $lastRSIQuoteRounded under $_lowStochasticValue and last RSI quote $lastRSIQuoteRounded under $_lowRSIQuoteParam"
            echo $resultStrategieUnderratedLowStochasticLowRSI
            WriteComdirectUrlAndStoreFileList $OUT_RESULT_FILE $symbol "$symbolName" true
        fi
    fi
}
