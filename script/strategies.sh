#!/bin/sh

# StrategieOverratedByTendency function:
# Strategie: last quote under tendency
# Input: _lastPriceParam($1), _tendencyParam($2), _percentageFactorParam($3), _lastAverage95Param${4}, _outResultFileParam($5), _symbolParam($6), _symbolNameParam($7), _markerOwnStockParam($8)
# Output: resultStrategieOverratedByTendency
StrategieOverratedByTendency() {
    _lastPriceParam=${1}
    _tendencyParam=${2}
    _percentageFactorParam=${3} # 1.01
    _lastAverage95Param=${4}
    _outResultFileParam=${5}
    _symbolParam=${6}
    _symbolNameParam=${7}
    _markerOwnStockParam=${8}
    export resultStrategieOverratedByTendency=""
    _alarmStrategieOverratedByTendency=0

#echo O11111

    # 0 times _percentageFactorParam
    _retRiseOverFalling=0
    if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_lastAverage95Param"')}'; then
        _retRiseOverFalling=1
        #echo O222
    fi     
    if [ "$_tendencyParam" = "falling" ] && [ "$_retRiseOverFalling" = 1 ]; then
        _alarmStrategieOverratedByTendency=1
    fi

    # 3 times _percentageFactorParam
    _percentagePowOf=$(echo "$_percentageFactorParam 3" | awk '{print $1 ^ $2}')
    _valueWithFactor=$(echo "$_percentagePowOf $_lastAverage95Param" | awk '{print $1 * $2}')
    _retRiseOverLevel=0
    if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_valueWithFactor"')}'; then
        _retRiseOverLevel=1
        #echo O333
    fi     
    if [ "$_tendencyParam" = "level" ] && [ "$_retRiseOverLevel" = 1 ]; then
        _alarmStrategieOverratedByTendency=1
    fi

    # 10 times _percentageFactorParam
    _percentagePowOf=$(echo "$_percentageFactorParam 10" | awk '{print $1 ^ $2}')
    _valueWithFactor=$(echo "$_percentagePowOf $_lastAverage95Param" | awk '{print $1 * $2}')
#echo _valueWithFactor "$_valueWithFactor"
    _retRiseWayOverRising=0
    if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_valueWithFactor"')}'; then
        _retRiseWayOverRising=1
        #echo O44444
    fi     
    if [ "$_tendencyParam" = "rising" ] && [ "$_retRiseWayOverRising" = 1 ]; then
        _alarmStrategieOverratedByTendency=1
         #echo O555
    fi

    if [ "$_alarmStrategieOverratedByTendency" = 1 ]; then
        reasonPrefix="Sell: High Quote by Tendency"
        resultStrategieOverratedByTendency="$reasonPrefix: $_lastPriceParam€ is over Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
        _linkColor=red
        if [ "${_markerOwnStockParam}" = '' ]; then
            _linkColor=black
        fi
        echo "$resultStrategieOverratedByTendency"
        WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
    fi
}

# StrategieUnderratedByTendency function:
# Strategie: last quote under tendency
# Input: _lastPriceParam($1), _tendencyParam($2), _percentageFactorParam($3), _lastAverage95Param${4}, _outResultFileParam($5), _symbolParam($6), _symbolNameParam($7), _markerOwnStockParam($8)
# Output: resultStrategieUnderratedByTendency
StrategieUnderratedByTendency() {
    _lastPriceParam=${1}
    _tendencyParam=${2}
    _percentageFactorParam=${3} # 1.01
    _lastAverage95Param=${4}
    _outResultFileParam=${5}
    _symbolParam=${6}
    _symbolNameParam=${7}
    _markerOwnStockParam=${8}
    export resultStrategieUnderratedByTendency=""
    _alarmStrategieUnderratedByTendency=0

#echo U11111

    # 0 times _percentageFactorParam
    _retDropUnderRising=0
    if awk 'BEGIN {exit !('"$_lastPriceParam"' < '"$_lastAverage95Param"')}'; then
        _retDropUnderRising=1
        #echo U2222
    fi     
    if [ "$_tendencyParam" = "rising" ] && [ "$_retDropUnderRising" = 1 ]; then
        _alarmStrategieUnderratedByTendency=1
    fi

    _retDropUnderLevel=0
    # 3 times _percentageFactorParam
    _percentagePowOf=$(echo "$_percentageFactorParam 3" | awk '{print $1 ^ $2}')
    _valueWithFactor=$(echo "$_percentagePowOf $_lastPriceParam" | awk '{print $1 * $2}')
    #_valueWithFactor=$(echo "$_percentageFactorParam $_valueWithFactor" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('"$_valueWithFactor"' < '"$_lastAverage95Param"')}'; then
        _retDropUnderLevel=1
        #echo U333
    fi     
    if [ "$_tendencyParam" = "level" ] && [ "$_retDropUnderLevel" = 1 ]; then
        _alarmStrategieUnderratedByTendency=1
    fi

    # 10 times _percentageFactorParam    
    _percentagePowOf=$(echo "$_percentageFactorParam 10" | awk '{print $1 ^ $2}')
    _valueWithFactor=$(echo "$_percentagePowOf $_lastPriceParam" | awk '{print $1 * $2}')
    _retDropWayUnderFalling=0
    if awk 'BEGIN {exit !('"$_valueWithFactor"' < '"$_lastAverage95Param"')}'; then
        _retDropWayUnderFalling=1
        #echo U444
    fi     
    if [ "$_tendencyParam" = "falling" ] && [ "$_retDropWayUnderFalling" = 1 ]; then
        _alarmStrategieUnderratedByTendency=1
    fi

    if [ "$_alarmStrategieUnderratedByTendency" = 1 ]; then
        reasonPrefix="Buy: Low Quote by Tendency"
        resultStrategieUnderratedByTendency="$reasonPrefix: $_lastPriceParam€ is under Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
        echo "$resultStrategieUnderratedByTendency"
        WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
    fi
}

# StrategieOverrated3HighRSI function:
# Strategie: High RSI 3 last values over highRSIValue
# Input is ${x}
# Output: resultStrategieOverrated3HighRSI
StrategieOverrated3HighRSI() {
    _highRSIValueParam=${1}
    _RSIQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    export resultStrategieOverrated3HighRSI=""
    if [ "${#_RSIQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        value_98=$(echo "$_RSIQuoteListParam" | cut -f 98 -d ',')
        value_99=$(echo "$_RSIQuoteListParam" | cut -f 99 -d ',')
        value_100=$(echo "$_RSIQuoteListParam" | cut -f 100 -d ',')
        # All 3 last values over _highRSIValueParam?
        if [ "$value_98" -gt "$_highRSIValueParam" ] && [ "$value_99" -gt "$_highRSIValueParam" ] && [ "$value_100" -gt "$_highRSIValueParam" ]; then
            reasonPrefix="Sell: High 3 last RSI"
            resultStrategieOverrated3HighRSI="$reasonPrefix: 3 last quotes are over $_highRSIValueParam"
            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            echo "$resultStrategieOverrated3HighRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieUnderrated3LowRSI function:
# Strategie: Low RSI 3 last values under lowRSIValue
# Input is ${x}
# Output: resultStrategieUnderrated3LowRSI
StrategieUnderrated3LowRSI() { 
    _lowRSIValueParam=${1}
    _RSIQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    export resultStrategieUnderrated3LowRSI=""
    if [ "${#_RSIQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        value_98=$(echo "$_RSIQuoteListParam" | cut -f 98 -d ',')
        value_99=$(echo "$_RSIQuoteListParam" | cut -f 99 -d ',')
        value_100=$(echo "$_RSIQuoteListParam" | cut -f 100 -d ',')
        # All 3 last values under _lowRSIValueParam?
        if [ "$value_98" -lt "$_lowRSIValueParam" ] && [ "$value_99" -lt "$_lowRSIValueParam" ] && [ "$value_100" -lt "$_lowRSIValueParam" ]; then
            reasonPrefix="Buy: Low 3 last RSI"
            resultStrategieUnderrated3LowRSI="$reasonPrefix: 3 last quotes are under $_lowRSIValueParam"
            echo "$resultStrategieUnderrated3LowRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
        fi           
    fi
}

# StrategieUnderratedLowRSI function:
# Strategie: Low RSI last quote under lowRSIValue
# https://www.charttec.de/html/indikator_rsi_relative_strength_index.php
# https://de.wikipedia.org/wiki/Relative_Strength_Index
# Input is _ratedParam($1), _lowRSIValueParam($2), _lastRSIQuoteRoundedParam($3), _outResultFileParam($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieUnderratedLowRSI
# StrategieUnderratedLowRSI() {
#     _ratedParam=${1}
#     _lowRSIValueParam=${2}
#     _lastRSIQuoteRoundedParam=${3}
#     _outResultFileParam=${4}
#     _symbolParam=${5}
#     _symbolNameParam=${6}
#     _markerOwnStockParam=${7}
#     export resultStrategieUnderratedLowRSI=""
#     if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
#         #resultStrategieUnderratedLowRSI=""
#         # Last RSI quote under _lowRSIValue
#         if [ "$_lastRSIQuoteRoundedParam" -lt "$_lowRSIValueParam" ]; then
             # reasonPrefix="Buy: Low last RSI"
#             resultStrategieUnderratedLowRSI="$reasonPrefix: RSI quote $_lastRSIQuoteRoundedParam under $_lowRSIValueParam"
        # echo "$resultStrategieUnderratedLowRSI"
#             WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
#         fi
#     fi
# }

# StrategieOverratedHighHorizontalMACD function:
# Strategie: MACD value high approch horizontal level. MACD must be in the positiv/upper half
# Input is ${x}
# Output: resultStrategieOverratedHighHorizontalMACD
StrategieOverratedHighHorizontalMACD() {
    _MACDQuoteListParam=${1} 
    _outResultFileParam=${2}
    _symbolParam=${3}
    _symbolNameParam=${4}
    _markerOwnStockParam=${5}
    export resultStrategieOverratedHighHorizontalMACD=""  
    if [ "${#_MACDQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Remove leading commas
        _MACDQuoteListParam=$(echo "$_MACDQuoteListParam" | cut -b 52-10000)
        jj_index=0
        # shellcheck disable=SC2001
        for valueMACD in $(echo "$_MACDQuoteListParam" | sed "s/,/ /g")
        do
            if [ "$jj_index" = 72 ]; then
                valueMACDLast_2="$valueMACD" 
            fi
            if [ "$jj_index" = 73 ]; then
                valueMACDLast_1="$valueMACD" 
            fi
            if [ "$jj_index" = 74 ]; then
                valueMACDLast_0="$valueMACD" 
            fi
            jj_index=$((jj_index + 1))
        done
        isMACDHorizontalAlarm=false
        # Check if MACD is horizontal?
        # BeforeLast Value
        difference=$(echo "$valueMACDLast_1 $valueMACDLast_2" | awk '{print ($1 - $2)}')
        isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
        # Positiv -> up
        # If first criterium positiv -> first step Alarm!
        if [ ! "${isNegativ}" = '-' ] || [ "${difference}" = 0 ]; then
            isMACDHorizontalAlarm=true
        fi

        # Last Value
        difference=$(echo "$valueMACDLast_0 $valueMACDLast_1" | awk '{print ($1 - $2)}')
        isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
        isMACDGenerellPositiv=$(echo "${valueMACDLast_1}" | awk '{print substr ($0, 0, 1)}')
        # If second criterium negativ -> Alarm!
        if { [ "${difference}" = 0 ] || [ "${isNegativ}" = '-' ]; } &&
            { [ ${isMACDHorizontalAlarm} = true ] && [ ! "${isMACDGenerellPositiv}" = '-' ]; } then
            isMACDHorizontalAlarm=true
        else
            isMACDHorizontalAlarm=false
        fi

        # is MACD horizontal?
        if [ "$isMACDHorizontalAlarm" = true ]; then
            reasonPrefix="Sell: High horizontal MACD"
            resultStrategieOverratedHighHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            echo "$resultStrategieOverratedHighHorizontalMACD"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieUnderratedLowHorizontalMACD function:
# Strategie: MACD value low approch horizontal level. MACD must be in the negativ/lower half
# Input is ${x}
# Output: resultStrategieUnderratedLowHorizontalMACD
StrategieUnderratedLowHorizontalMACD() {
    _MACDQuoteListParam=${1} 
    _outResultFileParam=${2}
    _symbolParam=${3}
    _symbolNameParam=${4}
    _markerOwnStockParam=${5}
    export resultStrategieUnderratedLowHorizontalMACD=""  
    if [ "${#_MACDQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Remove leading commas
        _MACDQuoteListParam=$(echo "$_MACDQuoteListParam" | cut -b 52-10000)
        jj_index=0
        # shellcheck disable=SC2001
        for valueMACD in $(echo "$_MACDQuoteListParam" | sed "s/,/ /g")
        do
            if [ "$jj_index" = 72 ]; then
                valueMACDLast_2="$valueMACD" 
            fi
            if [ "$jj_index" = 73 ]; then
                valueMACDLast_1="$valueMACD" 
            fi
            if [ "$jj_index" = 74 ]; then
                valueMACDLast_0="$valueMACD" 
            fi
            jj_index=$((jj_index + 1))
        done

        isMACDHorizontalAlarm=false
        # Check if MACD is horizontal?
        # BeforeLast Value
        difference=$(echo "$valueMACDLast_1 $valueMACDLast_2" | awk '{print ($1 - $2)}')
        isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
        # Negativ -> down
        # If first criterium negativ -> first step Alarm!
        if [ "${isNegativ}" = '-' ] || [ "${difference}" = 0 ]; then
            isMACDHorizontalAlarm=true
        fi

        # Last Value
        difference=$(echo "$valueMACDLast_0 $valueMACDLast_1" | awk '{print ($1 - $2)}')
        isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
        isMACDGenerellNegativ=$(echo "${valueMACDLast_1}" | awk '{print substr ($0, 0, 1)}')
        # If second criterium positiv -> Alarm!
        if [ ${isMACDHorizontalAlarm} = true ] && [ ! "${isNegativ}" = '-' ] && [ "${isMACDGenerellNegativ}" = '-' ]; then
            isMACDHorizontalAlarm=true
        else
            isMACDHorizontalAlarm=false
        fi

        # is MACD horizontal?
        if [ "$isMACDHorizontalAlarm" = true ]; then
            reasonPrefix="Buy: Low horizontal MACD"
            resultStrategieUnderratedLowHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
            echo "$resultStrategieUnderratedLowHorizontalMACD"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieOverratedByPercentAndStochastic function:
# Strategie: High Percentage & Stochastic
# Input: ${x}
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {
    _lastStochasticQuoteRoundedParam=${1}
    _stochasticPercentageUpperParam=${2}
    _lastOverAgv18Param=${3}
    _lastOverAgv38Param=${4}
    _lastOverAgv95Param=${5}
    _agv18OverAgv38Param=${6}
    _agv38OverAgv95Param=${7}
    _agv18OverAgv95Param=${8}
    _lastPriceParam=${9}
    _percentageLesserFactorParam=${10}
    _average18Param=${11}
    _average38Param=${12}
    _average95Param=${13}
    _outResultFileParam=${14}
    _symbolParam=${15}
    _symbolNameParam=${16}
    _markerOwnStockParam=${17}
    export resultStrategieOverratedByPercentAndStochastic=""
    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
        if [ "$_lastStochasticQuoteRoundedParam" -gt "$_stochasticPercentageUpperParam" ] && [ "$_lastOverAgv18Param" = 1 ] && [ "$_lastOverAgv38Param" = 1 ] && [ "$_lastOverAgv95Param" = 1 ] && 
            [ "$_agv18OverAgv38Param" = 1 ] && [ "$_agv38OverAgv95Param" = 1 ] && [ "$_agv18OverAgv95Param" = 1 ]; then
            reasonPrefix="Sell: High Percentage & Stochastic"
            resultStrategieOverratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageLesserFactorParam over Avg18 $_average18Param€ and Avg38 $_average38Param€ and Avg95 $_average95Param€ and Stoch14 is $_lastStochasticQuoteRoundedParam is higher then $_stochasticPercentageUpperParam"
            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            echo "$resultStrategieOverratedByPercentAndStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Low Percentage & Stochastic
# Input: ${x}
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() {
    _lastStochasticQuoteRoundedParam=${1}
    _stochasticPercentageLowerParam=${2}
    _lastUnderAgv18Param=${3}
    _lastUnderAgv38Param=${4}
    _lastUnderAgv95Param=${5}
    _agv18UnderAgv38Param=${6}
    _agv38UnderAgv95Param=${7}
    _agv18UnderAgv95Param=${8}
    _lastPriceParam=${9}
    _percentageGreaterFactorParam=${10}
    _average18Param=${11}
    _average38Param=${12}
    _average95Param=${13}
    _outResultFileParam=${14}
    _symbolParam=${15}
    _symbolNameParam=${16}
    _markerOwnStockParam=${17}
    export resultStrategieUnderratedByPercentAndStochastic=""
    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
        if [ "$_lastStochasticQuoteRoundedParam" -lt "$_stochasticPercentageLowerParam" ] && [ "$_lastUnderAgv18Param" = 1 ] && [ "$_lastUnderAgv38Param" = 1 ] && [ "$_lastUnderAgv95Param" = 1 ] && 
            [ "$_agv18UnderAgv38Param" = 1 ] && [ "$_agv38UnderAgv95Param" = 1 ] && [ "$_agv18UnderAgv95Param" = 1 ]; then
            reasonPrefix="Buy: Low Percentage & Stochastic"
            resultStrategieUnderratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageGreaterFactorParam under Avg18 $_average18Param€ and Avg38 $_average38Param€ and Avg95 $_average95Param€ and Stoch14 $_lastStochasticQuoteRoundedParam is lower then $_stochasticPercentageLowerParam"
            echo "$resultStrategieUnderratedByPercentAndStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieOverrated3HighStochastic function:
# Strategie: High Stochastic 3 last values over highStochasticValue
# Input is ${x}
# Output: resultStrategieOverrated3HighStochastic
StrategieOverrated3HighStochastic() {  
    _highStochasticValueParam=${1}
    _stochasticQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    export resultStrategieOverrated3HighStochastic=""
    if [ "${#_stochasticQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Revers and output the last x numbers. Attention only works for SINGLE digst numbers!
        _stochasticQuoteListParam=$(echo "$_stochasticQuoteListParam" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteListParam"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteListParam
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

        if [ "${#value1}" -gt 1 ] && [ "$value1" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value2}" -gt 1 ] && [ "$value2" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value3}" -gt 1 ] && [ "$value3" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi   
        # All 3 last values over _highStochasticValueParam?
        if [ "$howManyOverHighStochasticValue" -gt 2 ]; then   
            reasonPrefix="Sell: High 3 last Stochastic"
            resultStrategieOverrated3HighStochastic="$reasonPrefix: 3 last quotes are over $_highStochasticValueParam"
            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi
            echo "$resultStrategieOverrated3HighStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieUnderrated3LowStochastic function:
# Strategie: Low Stochastic 3 last values under lowStochasticValue
# Input is ${x}
# Output: resultStrategieUnderrated3LowStochastic
StrategieUnderrated3LowStochastic() {
    _lowStochasticValueParam=${1}
    _stochasticQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    export resultStrategieUnderrated3LowStochastic=""
    if [ "${#_stochasticQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Revers and output the last x numbers. Attention only works for single digst numbers!
        _stochasticQuoteListParam=$(echo "$_stochasticQuoteListParam" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteListParam"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteListParam
        # Cut comma, like: ",22" -> "22"
        value1=$(echo "$1" | cut -b 2-3)
        value2=$(echo "$2" | cut -b 2-3)
        value3=$(echo "$3" | cut -b 2-3)
        IFS=$OLDIFS
        howManyUnderLowStochasticValue=0
        # Check string length and low stochastic parameter
        if [ ! "${#value1}" -gt 1 ] && [ "$value1" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value2}" -gt 1 ] && [ "$value2" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value3}" -gt 1 ] && [ "$value3" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        # All 3 last values under _lowStochasticValueParam?
        if [ "$howManyUnderLowStochasticValue" -gt 2 ]; then
            reasonPrefix="Buy: Low 3 last Stochastic"
            resultStrategieUnderrated3LowStochastic="$reasonPrefix: 3 last quotes are under $_lowStochasticValueParam"
            echo "$resultStrategieUnderrated3LowStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieOverratedHighStochasticHighRSIHighMACD function:
# Strategie: High Stochastic and High RSI last quote over highRSIValue
# Input is ${x}
# Output: resultStrategieOverratedHighStochasticHighRSIHighMACD
StrategieOverratedHighStochasticHighRSIHighMACD() {
    _highStochasticValueParam=${1}
    _highRSIQuoteParam=${2}
    _lastStochasticQuoteRoundedParam=${3}
    _lastRSIQuoteRoundedParam=${4}
    _lastMACDValueParam=${5}
    _outResultFileParam=${6}
    _symbolParam=${7}
    _symbolNameParam=${8}  
    _markerOwnStockParam=${9}
    export resultStrategieOverratedHighStochasticHighRSIHighMACD=""
    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
        _lastMACDValueParamSign=$(echo "${_lastMACDValueParam}" | awk '{print substr ($0, 0, 1)}')
        # Last Stochastic quote over _highStochasticValueParam and Last RSI quote over _highRSIValue and _lastMACDValueParam is positiv
        if [ "$_lastStochasticQuoteRoundedParam" -gt "$_highStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -gt "$_highRSIQuoteParam" ] && [ ! "${_lastMACDValueParamSign}" = '-' ]; then
            reasonPrefix="Sell: High Stochastic & RSI & MACD+"
            resultStrategieOverratedHighStochasticHighRSIHighMACD="$reasonPrefix: Stochastic quote $_lastStochasticQuoteRoundedParam over $_highStochasticValueParam and RSI quote $_lastRSIQuoteRoundedParam over $_highRSIQuoteParam"
            # Red link only for stocks that are marked as own 
            _linkColor=red
            if [ "${_markerOwnStockParam}" = '' ]; then
                _linkColor=black
            fi     
            echo "$resultStrategieOverratedHighStochasticHighRSIHighMACD"                       
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSILowMACD function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue
# Input is ${x}
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSILowMACD() {
    _lowStochasticValueParam=${1}
    _lowRSIQuoteParam=${2}
    _lastStochasticQuoteRoundedParam=${3}
    _lastRSIQuoteRoundedParam=${4}
    _lastMACDValueParam=${5}
    _outResultFileParam=${6}
    _symbolParam=${7}
    _symbolNameParam=${8}
    _markerOwnStockParam=${9}
    export resultStrategieUnderratedLowStochasticLowRSILowMACD=""
    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
        _lastMACDValueParamSign=$(echo "${_lastMACDValueParam}" | awk '{print substr ($0, 0, 1)}')
        # Last Stochastic quote under _lowStochasticValueParam and Last RSI quote under _lowRSIValue and _lastMACDValueParam is negativ
        if [ "$_lastStochasticQuoteRoundedParam" -lt "$_lowStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -lt "$_lowRSIQuoteParam" ] && [ "${_lastMACDValueParamSign}" = '-' ]; then
            reasonPrefix="Buy: Low Stochastic & RSI & MACD-"
            resultStrategieUnderratedLowStochasticLowRSILowMACD="$reasonPrefix: Stochastic quote $_lastStochasticQuoteRoundedParam under $_lowStochasticValueParam and RSI quote $_lastRSIQuoteRoundedParam under $_lowRSIQuoteParam"
            echo "$resultStrategieUnderratedLowStochasticLowRSILowMACD"                       
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
        fi
    fi
}
