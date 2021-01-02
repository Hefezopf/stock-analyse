#!/bin/sh

# StrategieOverratedByPercentAndStochastic function:
# Strategie: High by Percent & Stochastic
# Input: ratedParam($1), lastStochasticQuoteRounded($2), stochasticPercentageUpper($3), lastOverAgv18($4), lastOverAgv38($5), lastOverAgv100($6), agv18OverAgv38($7), agv38OverAgv100($8), agv18OverAgv100($9), last($10), percentageLesserFactor($11), average18($12), average38($13), average100($14), OUT_RESULT_FILE_param($15), symbolParam($16), _symbolNameParam($17), _markerOwnStockParam($18)
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
    _OUT_RESULT_FILE_param=${15}
    _symbolParam=${16}
    _symbolNameParam=${17}
    _markerOwnStockParam=${18}
    resultStrategieOverratedByPercentAndStochastic=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "$_lastStochasticQuoteRounded" -gt "$_stochasticPercentageUpper" ] && [ "$_lastOverAgv18" = 1 ] && [ "$_lastOverAgv38" = 1 ] && [ "$_lastOverAgv100" = 1 ] && 
            [ "$_agv18OverAgv38" = 1 ] && [ "$_agv38OverAgv100" = 1 ] && [ "$_agv18OverAgv100" = 1 ]; then
            resultStrategieOverratedByPercentAndStochastic="- High by percent & stochastic: $_last€ is $_percentageLesserFactor over Avg18 $_average18€ and Avg38 $_average38€ and Avg100 $_average100€ and Stoch14 is $_lastStochasticQuoteRounded is higher then $_stochasticPercentageUpper"
            echo "$resultStrategieOverratedByPercentAndStochastic"

            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true "$_linkColor" "$_markerOwnStockParam"
        fi
    fi
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Low by Percent & Stochastic
# Input: ratedParam($1), lastStochasticQuoteRounded($2), stochasticPercentageLower($3), lastUnderAgv18($4), lastUnderAgv38($5), lastUnderAgv100($6), agv18UnderAgv38($7), agv38UnderAgv100($8), agv18UnderAgv100($9), last($10), percentageGreaterFactor($11), average18($12), average38($13), average100($14), stochasticPercentageLower($15), OUT_RESULT_FILE_param($16), symbolParam($17), _symbolNameParam($18), _markerOwnStockParam($19)
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() { 
    _ratedParam=${1}
    _lastStochasticQuoteRounded=${2}
    _stochasticPercentageLower=${3}
    _lastUnderAgv18=${4}
    _lastUnderAgv38=${5}
    _lastUnderAgv100=${6}
    _agv18UnderAgv38=${7}
    _agv38UnderAgv100=${8}
    _agv18UnderAgv100=${9}
    _last=${10}
    _percentageGreaterFactor=${11}
    _average18=${12}
    _average38=${13}
    _average100=${14}
    _stochasticPercentageLower=${15}
    _OUT_RESULT_FILE_param=${16}
    _symbolParam=${17}
    _symbolNameParam=${18}
    _markerOwnStockParam=${19}
    resultStrategieUnderratedByPercentAndStochastic=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "$_lastStochasticQuoteRounded" -lt "$_stochasticPercentageLower" ] && [ "$_lastUnderAgv18" = 1 ] && [ "$_lastUnderAgv38" = 1 ] && [ "$_lastUnderAgv100" = 1 ] && 
            [ "$_agv18UnderAgv38" = 1 ] && [ "$_agv38UnderAgv100" = 1 ] && [ "$_agv18UnderAgv100" = 1 ]; then
            resultStrategieUnderratedByPercentAndStochastic="+ Low by percent & stochastic: $_last€ is $_percentageGreaterFactor under Avg18 $_average18€ and Avg38 $_average38€ and Avg100 $_average100€ and Stoch14 $_lastStochasticQuoteRounded is lower then $_stochasticPercentageLower"
            echo "$resultStrategieUnderratedByPercentAndStochastic"
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true green "$_markerOwnStockParam"
        fi
    fi
}

# StrategieOverrated3HighStochastic function:
# Strategie: High stochastic 3 last values over highStochasticValue
# Input is _ratedParam($1), highStochasticValue($2), stochasticQuoteList($3), _OUT_RESULT_FILE_param($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieOverrated3HighStochastic
StrategieOverrated3HighStochastic() { 
    _ratedParam=${1}   
    _highStochasticValue=${2}
    _stochasticQuoteList=${3} 
    _OUT_RESULT_FILE_param=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieOverrated3HighStochastic=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
        # Revers and output the last x numbers. Attention only works for single digst numbers!
        _stochasticQuoteList=$(echo "$_stochasticQuoteList" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteList"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteList
        # Cut comma, like: ",22" -> "22"        
        value1=$(echo "$1" | cut -b 2-3)
        value2=$(echo "$2" | cut -b 2-3)
        value3=$(echo "$3" | cut -b 2-3)

        # revsers digits '18' will be '81'
        value1=$(echo "$value1" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value2=$(echo "$value2" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value3=$(echo "$value3" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        IFS=$OLDIFS
        howManyOverHighStochasticValue=0
        # Deal with 100
        if [ "$value1" = '00' ]; then
            value1=99
        fi
        if [ "$value2" = '00' ]; then
            value2=99
        fi
        if [ "$value3" = '00' ]; then
            value3=99
        fi

        if [ "${#value1}" -gt 1 ] && [ "$value1" -gt "$_highStochasticValue" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value2}" -gt 1 ] && [ "$value2" -gt "$_highStochasticValue" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value3}" -gt 1 ] && [ "$value3" -gt "$_highStochasticValue" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi   
        # All 3 last values over _highStochasticValue?
        if [ "$howManyOverHighStochasticValue" -gt 2 ]; then   
            resultStrategieOverrated3HighStochastic="- High 3 last stochastic: 3 last quotes are over $_highStochasticValue"
            echo "$resultStrategieOverrated3HighStochastic"

            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true "$_linkColor" "$_markerOwnStockParam"
        fi
    fi
}

# StrategieUnderrated3LowStochastic function:
# Strategie: Low stochastic 3 last values under lowStochasticValue
# Input is _ratedParam($1), lowStochasticValue($2), stochasticQuoteList($3), _OUT_RESULT_FILE_param($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieUnderrated3LowStochastic
StrategieUnderrated3LowStochastic() { 
    _ratedParam=${1}   
    _lowStochasticValue=${2}
    _stochasticQuoteList=${3} 
    _OUT_RESULT_FILE_param=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieUnderrated3LowStochastic=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
        # Revers and output the last x numbers. Attention only works for single digst numbers!
        _stochasticQuoteList=$(echo "$_stochasticQuoteList" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteList"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteList
        # Cut comma, like: ",22" -> "22"
        value1=$(echo "$1" | cut -b 2-3)
        value2=$(echo "$2" | cut -b 2-3)
        value3=$(echo "$3" | cut -b 2-3)

        IFS=$OLDIFS
        howManyUnderLowStochasticValue=0
        # Check string length and low stochastic parameter
        if [ ! "${#value1}" -gt 1 ] && [ "$value1" -lt "$_lowStochasticValue" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value2}" -gt 1 ] && [ "$value2" -lt "$_lowStochasticValue" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value3}" -gt 1 ] && [ "$value3" -lt "$_lowStochasticValue" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        # All 3 last values under _lowStochasticValue?
        if [ "$howManyUnderLowStochasticValue" -gt 2 ]; then
            resultStrategieUnderrated3LowStochastic="+ Low 3 last stochastic: 3 last quotes are under $_lowStochasticValue"
            echo "$resultStrategieUnderrated3LowStochastic"
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true green "$_markerOwnStockParam"
        fi
    fi
}

# StrategieOverratedHighStochasticHighRSI function:
# Strategie: High Stochastic and High RSI last quote over highRSIValue
# Input is _ratedParam($1), highStochasticValue($2), highRSIQuoteParam($3), _lastStochasticQuoteRounded($4), _lastRSIQuoteRounded($5), _OUT_RESULT_FILE_param($6), _symbolParam($7), _symbolNameParam($8), _markerOwnStockParam($9)
# Output: resultStrategieOverratedHighStochasticHighRSI
StrategieOverratedHighStochasticHighRSI() {    
    _ratedParam=${1}
    _highStochasticValue=${2}
    _highRSIQuoteParam=${3}
    _lastStochasticQuoteRounded=${4}
    _lastRSIQuoteRounded=${5}
    _OUT_RESULT_FILE_param=${6}
    _symbolParam=${7}
    _symbolNameParam=${8}  
    _markerOwnStockParam=${9}
    resultStrategieOverratedHighStochasticHighRSI=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then  
        # Last Stoch quote under _highStochasticValue and Last RSI quote under _highRSIValue
        if [ "$_lastStochasticQuoteRounded" -gt "$_highStochasticValue" ] && [ "$_lastRSIQuoteRounded" -gt "$_highRSIQuoteParam" ]; then
            resultStrategieOverratedHighStochasticHighRSI="- High last Stoch & RSI: Stoch quote $_lastStochasticQuoteRounded over $_highStochasticValue and RSI quote $_lastRSIQuoteRounded over $_highRSIQuoteParam"
            echo "$resultStrategieOverratedHighStochasticHighRSI"
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true green "$_markerOwnStockParam"
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSI function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue
# Input is _ratedParam($1), lowStochasticValue($2), lowRSIQuoteParam($3), _lastStochasticQuoteRounded($4), _lastRSIQuoteRounded($5), _OUT_RESULT_FILE_param($6), _symbolParam($7), _symbolNameParam($8), _markerOwnStockParam($9)
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSI() {    
    _ratedParam=${1}
    _lowStochasticValue=${2}
    _lowRSIQuoteParam=${3}
    _lastStochasticQuoteRounded=${4}
    _lastRSIQuoteRounded=${5}
    _OUT_RESULT_FILE_param=${6}
    _symbolParam=${7}
    _symbolNameParam=${8}  
    _markerOwnStockParam=${9}
    resultStrategieUnderratedLowStochasticLowRSI=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then  
        # Last Stoch quote under _lowStochasticValue and Last RSI quote under _lowRSIValue
        if [ "$_lastStochasticQuoteRounded" -lt "$_lowStochasticValue" ] && [ "$_lastRSIQuoteRounded" -lt "$_lowRSIQuoteParam" ]; then
            resultStrategieUnderratedLowStochasticLowRSI="+ Low last Stoch & RSI: Stoch quote $_lastStochasticQuoteRounded under $_lowStochasticValue and RSI quote $_lastRSIQuoteRounded under $_lowRSIQuoteParam"
            echo "$resultStrategieUnderratedLowStochasticLowRSI"
            WriteComdirectUrlAndStoreFileList "$_OUT_RESULT_FILE_param" "$_symbolParam" "$_symbolNameParam" true green "$_markerOwnStockParam"
        fi
    fi
}