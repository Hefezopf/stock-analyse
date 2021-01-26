#!/bin/sh

# StrategieOverrated3HighRSI function:
# Strategie: High RSI 3 last values over highRSIValue
# Input is _ratedParam($1), _highRSIValueParam($2), _RSIQuoteListParam($3), _outResultFileParam($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieOverrated3HighRSI
StrategieOverrated3HighRSI() {
    _ratedParam=${1}   
    _highRSIValueParam=${2}
    _RSIQuoteListParam=${3} 
    _outResultFileParam=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieOverrated3HighRSI=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "${#_RSIQuoteListParam}" -gt 1 ]; then # Check if value makes sense
            value_98=$(echo "$_RSIQuoteListParam" | cut -f 98 -d ',')
            value_99=$(echo "$_RSIQuoteListParam" | cut -f 99 -d ',')
            value_100=$(echo "$_RSIQuoteListParam" | cut -f 100 -d ',')
            # All 3 last values over _highRSIValueParam?
            if [ "$value_98" -gt "$_highRSIValueParam" ] && [ "$value_99" -gt "$_highRSIValueParam" ] && [ "$value_100" -gt "$_highRSIValueParam" ]; then
                reasonPrefix="Buy: High 3 last RSI"
                resultStrategieOverrated3HighRSI="$reasonPrefix: 3 last quotes are over $_highRSIValueParam"
                echo "$resultStrategieOverrated3HighRSI"
                # Red link only for stocks that are marked as own 
                _linkColor=red
                if [ "${_markerOwnStockParam}" = '' ]; then
                    _linkColor=black
                fi
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi            
    fi
}

# StrategieUnderrated3LowRSI function:
# Strategie: Low RSI 3 last values under lowRSIValue
# Input is _ratedParam($1), _lowRSIValueParam($2), _RSIQuoteListParam($3), _outResultFileParam($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieUnderrated3LowRSI
StrategieUnderrated3LowRSI() {
    _ratedParam=${1}   
    _lowRSIValueParam=${2}
    _RSIQuoteListParam=${3} 
    _outResultFileParam=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieUnderrated3LowRSI=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
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
#     resultStrategieUnderratedLowRSI=""
#     if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
#         #resultStrategieUnderratedLowRSI=""
#         # Last RSI quote under _lowRSIValue
#         if [ "$_lastRSIQuoteRoundedParam" -lt "$_lowRSIValueParam" ]; then
             # reasonPrefix="Buy: Low last RSI"
#             resultStrategieUnderratedLowRSI="$reasonPrefix: RSI quote $_lastRSIQuoteRoundedParam under $_lowRSIValueParam"
#             echo "$resultStrategieUnderratedLowRSI"
#             WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
#         fi
#     fi
# }

# StrategieOverratedHighHorizontalMACD function:
# Strategie: MACD value high approch horizontal level. MACD must be in the positiv/upper half
# Input is _ratedParam($1), _MACDQuoteListParam($2), _outResultFileParam($3), _symbolParam($4), _symbolNameParam($5), _markerOwnStockParam($6)
# Output: resultStrategieOverratedHighHorizontalMACD
StrategieOverratedHighHorizontalMACD() {
    _ratedParam=${1}   
    _MACDQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    resultStrategieOverratedHighHorizontalMACD=""  
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
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
                reasonPrefix="Sell: High Horizontal MACD"
                resultStrategieOverratedHighHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
                echo "$resultStrategieOverratedHighHorizontalMACD"
                # Red link only for stocks that are marked as own 
                _linkColor=red
                if [ "${_markerOwnStockParam}" = '' ]; then
                    _linkColor=black
                fi
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi            
    fi
}

# StrategieUnderratedLowHorizontalMACD function:
# Strategie: MACD value low approch horizontal level. MACD must be in the negativ/lower half
# Input is _ratedParam($1), _MACDQuoteListParam($2), _outResultFileParam($3), _symbolParam($4), _symbolNameParam($5), _markerOwnStockParam($6)
# Output: resultStrategieUnderratedLowHorizontalMACD
StrategieUnderratedLowHorizontalMACD() {
    _ratedParam=${1}   
    _MACDQuoteListParam=${2} 
    _outResultFileParam=${3}
    _symbolParam=${4}
    _symbolNameParam=${5}
    _markerOwnStockParam=${6}
    resultStrategieUnderratedLowHorizontalMACD=""  
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
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
                reasonPrefix="Buy: Low Horizontal MACD"
                resultStrategieUnderratedLowHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
                echo "$resultStrategieUnderratedLowHorizontalMACD"
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi            
    fi
}

# StrategieOverratedByPercentAndStochastic function:
# Strategie: High by Percent & Stochastic
# Input: _ratedParam($1), _lastStochasticQuoteRoundedParam($2), _stochasticPercentageUpperParam($3), _lastOverAgv18Param($4), _lastOverAgv38Param($5), _lastOverAgv100Param($6), _agv18OverAgv38Param($7), _agv38OverAgv100Param($8), _agv18OverAgv100Param($9), _lastPriceParam($10), _percentageLesserFactorParam($11), _average18Param($12), _average38Param($13), _average100Param($14), _outResultFileParam($15), _symbolParam($16), _symbolNameParam($17), _markerOwnStockParam($18)
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {
    _ratedParam=${1}
    _lastStochasticQuoteRoundedParam=${2}
    _stochasticPercentageUpperParam=${3}
    _lastOverAgv18Param=${4}
    _lastOverAgv38Param=${5}
    _lastOverAgv100Param=${6}
    _agv18OverAgv38Param=${7}
    _agv38OverAgv100Param=${8}
    _agv18OverAgv100Param=${9}
    _lastPriceParam=${10}
    _percentageLesserFactorParam=${11}
    _average18Param=${12}
    _average38Param=${13}
    _average100Param=${14}
    _outResultFileParam=${15}
    _symbolParam=${16}
    _symbolNameParam=${17}
    _markerOwnStockParam=${18}
    resultStrategieOverratedByPercentAndStochastic=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
            if [ "$_lastStochasticQuoteRoundedParam" -gt "$_stochasticPercentageUpperParam" ] && [ "$_lastOverAgv18Param" = 1 ] && [ "$_lastOverAgv38Param" = 1 ] && [ "$_lastOverAgv100Param" = 1 ] && 
                [ "$_agv18OverAgv38Param" = 1 ] && [ "$_agv38OverAgv100Param" = 1 ] && [ "$_agv18OverAgv100Param" = 1 ]; then
                reasonPrefix="Sell: High by percent & stochastic"
                resultStrategieOverratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageLesserFactorParam over Avg18 $_average18Param€ and Avg38 $_average38Param€ and Avg100 $_average100Param€ and Stoch14 is $_lastStochasticQuoteRoundedParam is higher then $_stochasticPercentageUpperParam"
                echo "$resultStrategieOverratedByPercentAndStochastic"
                # Red link only for stocks that are marked as own 
                _linkColor=red
                if [ "${_markerOwnStockParam}" = '' ]; then
                    _linkColor=black
                fi
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi
    fi
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Low by Percent & Stochastic
# Input: _ratedParam($1), _lastStochasticQuoteRoundedParam($2), _stochasticPercentageLowerParam($3), _lastUnderAgv18Param($4), _lastUnderAgv38Param($5), _lastUnderAgv100Param($6), _agv18UnderAgv38Param($7), _agv38UnderAgv100Param($8), _agv18UnderAgv100Param($9), _lastPriceParam($10), _percentageGreaterFactorParam($11), _average18Param($12), _average38Param($13), _average100Param($14), _stochasticPercentageLowerParam($15), _outResultFileParam($16), _symbolParam($17), _symbolNameParam($18), _markerOwnStockParam($19)
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() {
    _ratedParam=${1}
    _lastStochasticQuoteRoundedParam=${2}
    _stochasticPercentageLowerParam=${3}
    _lastUnderAgv18Param=${4}
    _lastUnderAgv38Param=${5}
    _lastUnderAgv100Param=${6}
    _agv18UnderAgv38Param=${7}
    _agv38UnderAgv100Param=${8}
    _agv18UnderAgv100Param=${9}
    _lastPriceParam=${10}
    _percentageGreaterFactorParam=${11}
    _average18Param=${12}
    _average38Param=${13}
    _average100Param=${14}
    _stochasticPercentageLowerParam=${15}
    _outResultFileParam=${16}
    _symbolParam=${17}
    _symbolNameParam=${18}
    _markerOwnStockParam=${19}
    resultStrategieUnderratedByPercentAndStochastic=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
            if [ "$_lastStochasticQuoteRoundedParam" -lt "$_stochasticPercentageLowerParam" ] && [ "$_lastUnderAgv18Param" = 1 ] && [ "$_lastUnderAgv38Param" = 1 ] && [ "$_lastUnderAgv100Param" = 1 ] && 
                [ "$_agv18UnderAgv38Param" = 1 ] && [ "$_agv38UnderAgv100Param" = 1 ] && [ "$_agv18UnderAgv100Param" = 1 ]; then
                reasonPrefix="Buy: Low by percent & stochastic"
                resultStrategieUnderratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageGreaterFactorParam under Avg18 $_average18Param€ and Avg38 $_average38Param€ and Avg100 $_average100Param€ and Stoch14 $_lastStochasticQuoteRoundedParam is lower then $_stochasticPercentageLowerParam"
                echo "$resultStrategieUnderratedByPercentAndStochastic"
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi
    fi
}

# StrategieOverrated3HighStochastic function:
# Strategie: High stochastic 3 last values over highStochasticValue
# Input is _ratedParam($1), highStochasticValue($2), stochasticQuoteList($3), _outResultFileParam($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieOverrated3HighStochastic
StrategieOverrated3HighStochastic() {
    _ratedParam=${1}   
    _highStochasticValueParam=${2}
    _stochasticQuoteListParam=${3} 
    _outResultFileParam=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieOverrated3HighStochastic=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
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
                reasonPrefix="Sell: High 3 last stochastic"
                resultStrategieOverrated3HighStochastic="$reasonPrefix: 3 last quotes are over $_highStochasticValueParam"
                echo "$resultStrategieOverrated3HighStochastic"
                # Red link only for stocks that are marked as own 
                _linkColor=red
                if [ "${_markerOwnStockParam}" = '' ]; then
                    _linkColor=black
                fi
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi
    fi
}

# StrategieUnderrated3LowStochastic function:
# Strategie: Low stochastic 3 last values under lowStochasticValue
# Input is _ratedParam($1), _lowStochasticValueParam($2), _stochasticQuoteListParam($3), _outResultFileParam($4), _symbolParam($5), _symbolNameParam($6), _markerOwnStockParam($7)
# Output: resultStrategieUnderrated3LowStochastic
StrategieUnderrated3LowStochastic() {
    _ratedParam=${1}   
    _lowStochasticValueParam=${2}
    _stochasticQuoteListParam=${3} 
    _outResultFileParam=${4}
    _symbolParam=${5}
    _symbolNameParam=${6}
    _markerOwnStockParam=${7}
    resultStrategieUnderrated3LowStochastic=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then
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
                reasonPrefix="Buy: Low 3 last stochastic"
                resultStrategieUnderrated3LowStochastic="$reasonPrefix: 3 last quotes are under $_lowStochasticValueParam"
                echo "$resultStrategieUnderrated3LowStochastic"
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi            
    fi
}

# StrategieOverratedHighStochasticHighRSIHighMACD function:
# Strategie: High Stochastic and High RSI last quote over highRSIValue
# Input is _ratedParam($1), highStochasticValue($2), highRSIQuoteParam($3), _lastStochasticQuoteRoundedParam($4), _lastRSIQuoteRoundedParam($5), _lastMACDValueParam=($6) _outResultFileParam($7), _symbolParam($8), _symbolNameParam($9), _markerOwnStockParam($10)
# Output: resultStrategieOverratedHighStochasticHighRSIHighMACD
StrategieOverratedHighStochasticHighRSIHighMACD() {
    _ratedParam=${1}
    _highStochasticValueParam=${2}
    _highRSIQuoteParam=${3}
    _lastStochasticQuoteRoundedParam=${4}
    _lastRSIQuoteRoundedParam=${5}
    _lastMACDValueParam=${6}
    _outResultFileParam=${7}
    _symbolParam=${8}
    _symbolNameParam=${9}  
    _markerOwnStockParam=${10}
    resultStrategieOverratedHighStochasticHighRSIHighMACD=""
    if [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'all' ]; then
        if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
            _lastMACDValueParamSign=$(echo "${_lastMACDValueParam}" | awk '{print substr ($0, 0, 1)}')
            # Last Stoch quote over _highStochasticValueParam and Last RSI quote over _highRSIValue and _lastMACDValueParam is positiv
            if [ "$_lastStochasticQuoteRoundedParam" -gt "$_highStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -gt "$_highRSIQuoteParam" ] && [ ! "${_lastMACDValueParamSign}" = '-' ]; then
                reasonPrefix="Sell: High last Stoch & RSI & MACD positiv"
                resultStrategieOverratedHighStochasticHighRSIHighMACD="$reasonPrefix: Stoch quote $_lastStochasticQuoteRoundedParam over $_highStochasticValueParam and RSI quote $_lastRSIQuoteRoundedParam over $_highRSIQuoteParam"
                echo "$resultStrategieOverratedHighStochasticHighRSIHighMACD"
                # Red link only for stocks that are marked as own 
                _linkColor=red
                if [ "${_markerOwnStockParam}" = '' ]; then
                    _linkColor=black
                fi            
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$_linkColor" "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSILowMACD function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue
# Input is _ratedParam($1), lowStochasticValue($2), lowRSIQuoteParam($3), _lastStochasticQuoteRoundedParam($4), _lastRSIQuoteRoundedParam($5), _lastMACDValueParam=($6) _outResultFileParam($7), _symbolParam($8), _symbolNameParam($9), _markerOwnStockParam($10)
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSILowMACD() {
    _ratedParam=${1}
    _lowStochasticValueParam=${2}
    _lowRSIQuoteParam=${3}
    _lastStochasticQuoteRoundedParam=${4}
    _lastRSIQuoteRoundedParam=${5}
    _lastMACDValueParam=${6}
    _outResultFileParam=${7}
    _symbolParam=${8}
    _symbolNameParam=${9}  
    _markerOwnStockParam=${10}
    resultStrategieUnderratedLowStochasticLowRSILowMACD=""
    if [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; then 
        if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
            _lastMACDValueParamSign=$(echo "${_lastMACDValueParam}" | awk '{print substr ($0, 0, 1)}')
            # Last Stoch quote under _lowStochasticValueParam and Last RSI quote under _lowRSIValue and _lastMACDValueParam is negativ
            if [ "$_lastStochasticQuoteRoundedParam" -lt "$_lowStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -lt "$_lowRSIQuoteParam" ] && [ "${_lastMACDValueParamSign}" = '-' ]; then
                reasonPrefix="Buy: Low last Stoch & RSI & MACD negativ"
                resultStrategieUnderratedLowStochasticLowRSILowMACD="$reasonPrefix: Stoch quote $_lastStochasticQuoteRoundedParam under $_lowStochasticValueParam and RSI quote $_lastRSIQuoteRoundedParam under $_lowRSIQuoteParam"
                echo "$resultStrategieUnderratedLowStochasticLowRSILowMACD"
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" green "$_markerOwnStockParam" "$reasonPrefix"
            fi
        fi
    fi
}
