#!/bin/bash

# StrategieUnderratedNewLow function:
# Strategie: New Low (N)
# Input: ${x}
# Output: resultStrategieUnderratedNewLow
StrategieUnderratedNewLow() { 
    _count=$1
    _commaPriceList=$2
    _last=$3
    _beforeLastQuote=$4
    _outResultFileParam=$5
    _symbolParam=$6
    _symbolNameParam=$7
    _markerOwnStockParam=$8
    export resultStrategieUnderratedNewLow=""

    newLow=$(echo "$_last" "$_beforeLastQuote" | awk '{if ($1 < $2) print "true"; else print "false"}')
    if [ "$newLow" = true ]; then
        i=85 # not last and not beforeLast!
        howManyValues=$((86-_count))
        while [ "$i" -ge $howManyValues ]; do
            # shellcheck disable=SC2086,SC2027
            valueNewLow=$(echo ""$_commaPriceList"" | cut -f$i -d",")
            conditionNewLow=$(echo "$_last" "$valueNewLow" | awk '{if ($1 < $2) print "true"; else print "false"}')
            if [ "$conditionNewLow" = false ]; then
                break;
            fi
            i=$((i - 1))
        done

        if [ "$conditionNewLow" = true ]; then
            alarmAbbrevValue="N+"$alarmAbbrevValue
            reasonPrefix="Buy: New $_count days Low (N)"
            resultStrategieUnderratedNewLow="$reasonPrefix"
            echo "$resultStrategieUnderratedNewLow"
            # shellcheck disable=SC2154
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieOverratedStochasticWhenOwn function:
# Overrated Stochastic when own stock
# Strategie: Stochastic Own (O)
# Input: ${x}
# Output: resultStrategieOverratedStochasticWhenOwn
StrategieOverratedStochasticWhenOwn() { 
    _highStochValueParam=$1
    _lastStochParam=$2
    _outResultFileParam=$3
    _symbolParam=$4
    _symbolNameParam=$5
    _markerOwnStockParam=$6
    export resultStrategieOverratedStochasticWhenOwn=""

    if [ "$_lastStochParam" -gt "$_highStochValueParam" ]; then     
       ## if [ "$_beforeLastStochParam" -le "$_highStochValueParam" ]; then     
            if [ "$_markerOwnStockParam" = '*' ]; then
                alarmAbbrevValue="O-"$alarmAbbrevValue
                reasonPrefix="Sell: Stochastic Own (O)"
                resultStrategieOverratedStochasticWhenOwn="$reasonPrefix"
                echo "$resultStrategieOverratedStochasticWhenOwn"
                WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"     
            fi
       ## fi
    fi
}

# StrategieOverratedDivergenceRSI function:
# Divergence RSI
# Strategie: RSI divergence (D)
# Input: ${x}
# Output: resultStrategieOverratedDivergenceRSI
StrategieOverratedDivergenceRSI() { 
    _highRSIValueParam=$1
    _outResultFileParam=$2
    _symbolParam=$3
    _symbolNameParam=$4
    _markerOwnStockParam=$5
    _lastMACDParam=$6
    _lastQuoteParam=$7
    _beforeLastQuoteParam=$8
    _lastRSIParam=$9
    _beforeLastRSIParam=${10} # 10th and more need {}
    export resultStrategieOverratedDivergenceRSI=""

    isMACDNegativ=$(echo "$_lastMACDParam" | awk '{print substr ($0, 0, 1)}')
    if [ "$_lastRSIParam" -gt "$_highRSIValueParam" ] && [ "$isMACDNegativ" != '-' ]; then
        newHigh=$(echo "$_lastQuoteParam" "$_beforeLastQuoteParam" | awk '{if ($1 > $2) print "true"; else print "false"}')      
        if [ "$newHigh" = true ] && [ "$_lastRSIParam" -le "$_beforeLastRSIParam" ]; then
            alarmAbbrevValue="D-"$alarmAbbrevValue
            reasonPrefix="Sell: RSI Divergence (D)"
            resultStrategieOverratedDivergenceRSI="$reasonPrefix"
            echo "$resultStrategieOverratedDivergenceRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedDivergenceRSI function:
# Divergence RSI
# Strategie: RSI divergence (D)
# Input: ${x}
# Output: resultStrategieUnderratedDivergenceRSI
StrategieUnderratedDivergenceRSI() { 
    _lowRSIValueParam=$1
    _outResultFileParam=$2
    _symbolParam=$3
    _symbolNameParam=$4
    _markerOwnStockParam=$5
    _lastMACDParam=$6
    _lastQuoteParam=$7
    _beforeLastQuoteParam=$8
    _lastRSIParam=$9
    _lowestRSIParam=${10} # 10th and more need {}
    _conditionNewLowParam=${11} # 11th and more need {}
    export resultStrategieUnderratedDivergenceRSI=""

    isMACDNegativ=$(echo "$_lastMACDParam" | awk '{print substr ($0, 0, 1)}')
    if [ "$isMACDNegativ" = '-' ]; then
        if [ "$_conditionNewLowParam" = true ] && [ "$_lastRSIParam" -ge "$_lowestRSIParam" ]; then
            alarmAbbrevValue="D+"$alarmAbbrevValue
            reasonPrefix="Buy: RSI Divergence (D)"
            resultStrategieUnderratedDivergenceRSI="$reasonPrefix"
            echo "$resultStrategieUnderratedDivergenceRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieByTendency function:
# Strategie: last quote in relation to tendency
# Input: ${x}
# Output: resultStrategieByTendency
StrategieByTendency() {
    _lastPriceParam=$1
    _tendencyParam=$2
    _percentageFactorParam=$3 # 1.01
    _lastAverage95Param=$4
    _outResultFileParam=$5
    _symbolParam=$6
    _symbolNameParam=$7
    _markerOwnStockParam=$8
    export resultStrategieByTendency=""

    if [ "$_tendencyParam" = "$RISING" ]; then
        # 0 times _percentageFactorParam
        if awk 'BEGIN {exit !('"$_lastPriceParam"' < '"$_lastAverage95Param"')}'; then
            alarmAbbrevValue=T+$alarmAbbrevValue
            reasonPrefix="Buy: Low Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is under Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
        # 10 times _percentageFactorParam
        _percentagePowOf=$(echo "$_percentageFactorParam 10" | awk '{print $1 ^ $2}')
        _valueWithFactor=$(echo "$_percentagePowOf $_lastAverage95Param" | awk '{print $1 * $2}')
        if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_valueWithFactor"')}'; then
            alarmAbbrevValue=T-$alarmAbbrevValue
            reasonPrefix="Sell: High Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is over Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    elif [ "$_tendencyParam" = "$LEVEL" ]; then 
        # 3 times _percentageFactorParam
        _percentagePowOf=$(echo "$_percentageFactorParam 3" | awk '{print $1 ^ $2}')
        _valueWithFactor=$(echo "$_percentagePowOf $_lastAverage95Param" | awk '{print $1 * $2}')
        if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_valueWithFactor"')}'; then
            alarmAbbrevValue=T-$alarmAbbrevValue
            reasonPrefix="Sell: High Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is over Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
        _valueWithFactor=$(echo "$_percentagePowOf $_lastPriceParam" | awk '{print $1 * $2}')       
        if awk 'BEGIN {exit !('"$_valueWithFactor"' < '"$_lastAverage95Param"')}'; then
            alarmAbbrevValue=T+$alarmAbbrevValue
            reasonPrefix="Buy: Low Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is under Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"        
        fi        
    elif [ "$_tendencyParam" = "$FALLING" ]; then 
        # 0 times _percentageFactorParam
        if awk 'BEGIN {exit !('"$_lastPriceParam"' > '"$_lastAverage95Param"')}'; then
            alarmAbbrevValue=T-$alarmAbbrevValue
            reasonPrefix="Sell: High Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is over Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
        # 10 times _percentageFactorParam
        _percentagePowOf=$(echo "$_percentageFactorParam 10" | awk '{print $1 ^ $2}')
        _valueWithFactor=$(echo "$_percentagePowOf $_lastPriceParam" | awk '{print $1 * $2}')
        if awk 'BEGIN {exit !('"$_valueWithFactor"' < '"$_lastAverage95Param"')}'; then
            alarmAbbrevValue=T+$alarmAbbrevValue
            reasonPrefix="Buy: Low Quote by Tendency (T)"
            resultStrategieByTendency="$reasonPrefix: $_lastPriceParam€ is under Avg95 $_lastAverage95Param€ with Tendency $_tendencyParam"
            echo "$resultStrategieByTendency"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieOverratedXHighRSI function:
# At least 3 high values out of 7 and one of the last 3 must be over. List of 87 comma seperated values
# Strategie: High RSI X last values over highRSIValue
# Input: ${x}
# Output: resultStrategieOverratedXHighRSI
StrategieOverratedXHighRSI() {
    _highRSIValueParam=$1
    _RSIQuoteListParam=$2
    _outResultFileParam=$3
    _symbolParam=$4
    _symbolNameParam=$5
    _markerOwnStockParam=$6
    export resultStrategieOverratedXHighRSI=""

    if [ "${#_RSIQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        value_81=$(echo "$_RSIQuoteListParam" | cut -f 81 -d ',')
        value_82=$(echo "$_RSIQuoteListParam" | cut -f 82 -d ',')
        value_83=$(echo "$_RSIQuoteListParam" | cut -f 83 -d ',')
        value_84=$(echo "$_RSIQuoteListParam" | cut -f 84 -d ',')
        value_85=$(echo "$_RSIQuoteListParam" | cut -f 85 -d ',')
        value_86=$(echo "$_RSIQuoteListParam" | cut -f 86 -d ',')
        value_87=$(echo "$_RSIQuoteListParam" | cut -f 87 -d ',')   
        countHighRSI=0
        oneOfTheLastRSIHigh=0
        if [ "$value_87" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
            oneOfTheLastRSIHigh=1
        fi           
        if [ "$value_86" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
            oneOfTheLastRSIHigh=1
        fi      
             
        if [ "$value_85" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
        fi           
        if [ "$value_84" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
        fi           
        if [ "$value_83" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
        fi
        if [ "$value_82" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
        fi
        if [ "$value_81" -gt "$_highRSIValueParam" ]; then
            countHighRSI=$((countHighRSI + 1))
        fi
        # At least 3 high values out of 7 and one of the last 3 must be over
        if [ "$countHighRSI" -ge 3 ] && [ "$oneOfTheLastRSIHigh" = 1 ]; then 
            alarmAbbrevValue=$countHighRSI"R-"$alarmAbbrevValue      
            reasonPrefix="Sell: High $countHighRSI last RSI (R)"
            resultStrategieOverratedXHighRSI="$reasonPrefix: $countHighRSI last quotes over level"
            echo "$resultStrategieOverratedXHighRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedXLowRSI function:
# At least 3 low values out of 7 and one of the last 3 must be under. List of 87 comma seperated values
# Strategie: Low RSI X last values under lowRSIValue
# Input: ${x}
# Output: resultStrategieUnderratedXLowRSI
StrategieUnderratedXLowRSI() { 
    _lowRSIValueParam=$1
    _RSIQuoteListParam=$2 
    _outResultFileParam=$3
    _symbolParam=$4
    _symbolNameParam=$5
    _markerOwnStockParam=$6
    export resultStrategieUnderratedXLowRSI=""

    if [ "${#_RSIQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        value_81=$(echo "$_RSIQuoteListParam" | cut -f 81 -d ',')
        value_82=$(echo "$_RSIQuoteListParam" | cut -f 82 -d ',')
        value_83=$(echo "$_RSIQuoteListParam" | cut -f 83 -d ',')
        value_84=$(echo "$_RSIQuoteListParam" | cut -f 84 -d ',')
        value_85=$(echo "$_RSIQuoteListParam" | cut -f 85 -d ',')
        value_86=$(echo "$_RSIQuoteListParam" | cut -f 86 -d ',')
        value_87=$(echo "$_RSIQuoteListParam" | cut -f 87 -d ',')
        countLowRSI=0
        oneOfTheLastRSILow=0
        if [ "$value_87" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
            oneOfTheLastRSILow=1
        fi           
        if [ "$value_86" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
            oneOfTheLastRSILow=1
        fi

        if [ "$value_85" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
        fi           
        if [ "$value_84" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
        fi           
        if [ "$value_83" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
        fi
        if [ "$value_82" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
        fi
        if [ "$value_81" -lt "$_lowRSIValueParam" ]; then
            countLowRSI=$((countLowRSI + 1))
        fi
        # At least 3 low values out of 7 and one of the last 3 must be under
        if [ "$countLowRSI" -ge 3 ] && [ "$oneOfTheLastRSILow" = 1 ]; then
            alarmAbbrevValue=$countLowRSI"R+"$alarmAbbrevValue
            reasonPrefix="Buy: Low $countLowRSI last RSI (R)"
            resultStrategieUnderratedXLowRSI="$reasonPrefix: $countLowRSI last quotes under level"
            echo "$resultStrategieUnderratedXLowRSI"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi                  
    fi
}

# StrategieOverratedHighHorizontalMACD function:
# Strategie: MACD value high approch level. MACD must be in the positiv/upper half
# Input: ${x}
# Output: resultStrategieOverratedHighHorizontalMACD
StrategieOverratedHighHorizontalMACD() {
    _MACDQuoteListParam=$1
    _outResultFileParam=$2
    _symbolParam=$3
    _symbolNameParam=$4
    _markerOwnStockParam=$5
    export resultStrategieOverratedHighHorizontalMACD="" 
   
    if [ "${#_MACDQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Remove leading commas
        _MACDQuoteListParam=$(echo "$_MACDQuoteListParam" | cut -b 26-10000)
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
        isNegativ=$(echo "$difference" | awk '{print substr ($0, 0, 1)}')
        # Positiv -> up
        # If first criterium positiv -> first step Alarm!
        if [ ! "$isNegativ" = '-' ] || [ "$difference" = 0 ]; then
            # Last Value
            difference=$(echo "$valueMACDLast_0 $valueMACDLast_1" | awk '{print ($1 - $2)}')
            difference0_2=$(echo "$valueMACDLast_0 $valueMACDLast_2" | awk '{print ($1 - $2)}')
            isMACDGenerellPositiv=$(echo "$valueMACDLast_1" | awk '{print substr ($0, 0, 1)}')
            isDifference0_2Positiv=$(echo "$difference0_2" | awk '{print substr ($0, 0, 1)}')
            # If second criterium negativ -> Alarm!
            if [ "$difference" = 0 ] && [ ! "$isMACDGenerellPositiv" = '-' ] && [ ! "$isDifference0_2Positiv" = '-' ]; then
                isMACDHorizontalAlarm=true
            else
                isMACDHorizontalAlarm=false
            fi
        fi
        # is MACD horizontal?
        if [ "$isMACDHorizontalAlarm" = true ]; then
            alarmAbbrevValue=M-$alarmAbbrevValue
            reasonPrefix="Sell: High MACD (M)"
            resultStrategieOverratedHighHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
            echo "$resultStrategieOverratedHighHorizontalMACD"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedLowHorizontalMACD function:
# Strategie: MACD value low approch level. MACD must be in the negativ/lower half
# Input: ${x}
# Output: resultStrategieUnderratedLowHorizontalMACD
StrategieUnderratedLowHorizontalMACD() {
    _MACDQuoteListParam=$1
    _outResultFileParam=$2
    _symbolParam=$3
    _symbolNameParam=$4
    _markerOwnStockParam=$5
    export resultStrategieUnderratedLowHorizontalMACD=""

#echo "_MACDQuoteListParam $_MACDQuoteListParam"

    if [ "${#_MACDQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Remove leading commas
        _MACDQuoteListParam=$(echo "$_MACDQuoteListParam" | cut -b 26-10000)
        jj_index=0
        valueNewMACDLow=100
        # shellcheck disable=SC2001
        for valueMACD in $(echo "$_MACDQuoteListParam" | sed "s/,/ /g")
        do
            # isValueMACDNegativ=$(echo "$valueMACD" | awk '{print substr ($0, 0, 1)}')
            # if [ "$isValueMACDNegativ" != '-' ] || [ "$valueMACD" = 0 ]; then
            #     valueNewMACDLow=0
            # fi

            if [ "$jj_index" = 71 ]; then
                valueMACDLast_3="$valueMACD" 
            fi
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

            isMACDHorizontalAlarm1=false
            isNewMACDLower=$(echo "$valueMACD" "$valueNewMACDLow" | awk '{if ($1 <= $2) print "true"; else print "false"}')
#echo "isNewMACDLower $isNewMACDLower jj_index $jj_index valueMACD $valueMACD"
            if [ "$isNewMACDLower" = true ]; then    
                valueNewMACDLow="$valueMACD"    
                isNegativMACDLast_0=$(echo "$valueMACDLast_0" | awk '{print substr ($0, 0, 1)}')
                isNegativMACDLast_1=$(echo "$valueMACDLast_1" | awk '{print substr ($0, 0, 1)}')
                isNegativMACDLast_2=$(echo "$valueMACDLast_2" | awk '{print substr ($0, 0, 1)}')
                isNegativMACDLast_3=$(echo "$valueMACDLast_3" | awk '{print substr ($0, 0, 1)}')              
                if [ "$isNegativMACDLast_0" = '-' ] && [ "$isNegativMACDLast_1" = '-' ] && [ "$isNegativMACDLast_2" = '-' ] && [ "$isNegativMACDLast_3" = '-' ]; then
                    isMACDHorizontalAlarm1=true
                fi
            else
                valueNewMACDLow="$valueMACD"
            fi
        done
  
        # Check if MACD is horizontal?
        # BeforeLast Value
        difference=$(echo "$valueMACDLast_1 $valueMACDLast_2" | awk '{print ($1 - $2)}')
        isNegativ=$(echo "$difference" | awk '{print substr ($0, 0, 1)}')      
        # Negativ -> down
        # If first criterium negativ -> first step Alarm!
        if [ "$isNegativ" = '-' ] || [ "$difference" = 0 ]; then
            # Last Value
            difference0_1=$(echo "$valueMACDLast_0 $valueMACDLast_1" | awk '{print ($1 - $2)}')
            difference0_2=$(echo "$valueMACDLast_0 $valueMACDLast_2" | awk '{print ($1 - $2)}')
            isDifference0_1Negativ=$(echo "$difference0_1" | awk '{print substr ($0, 0, 1)}')
            # If second criterium positiv -> Alarm!
            if [ "$isDifference0_1Negativ" = '-' ] || [ "$difference0_1" = 0 ]; then
                isMACDHorizontalAlarm2=true
            else           
                isMACDHorizontalAlarm2=false
            fi
        fi
        # is MACD horizontal?
        if [ "$isMACDHorizontalAlarm1" = true ] && [ "$isMACDHorizontalAlarm2" = true ]; then
            alarmAbbrevValue=M+$alarmAbbrevValue
            reasonPrefix="Buy: Low MACD (M)"
            resultStrategieUnderratedLowHorizontalMACD="$reasonPrefix: last MACD $valueMACDLast_0"
            echo "$resultStrategieUnderratedLowHorizontalMACD"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieOverratedByPercentAndStochastic function:
# Strategie: High Percent & Stochastic
# Input: ${x}
# Output: resultStrategieOverratedByPercentAndStochastic
StrategieOverratedByPercentAndStochastic() {
    _lastStochasticQuoteRoundedParam=$1
    _stochasticPercentageUpperParam=$2
    _lastOverAgv18Param=$3
    _lastOverAgv38Param=$4
    _lastOverAgv95Param=$5
    _agv18OverAgv38Param=$6
    _agv38OverAgv95Param=$7
    _agv18OverAgv95Param=$8
    _lastPriceParam=$9
    _percentageLesserFactorParam=${10} # 10th and more need {}
    _outResultFileParam=${11}
    _symbolParam=${12}
    _symbolNameParam=${13}
    _markerOwnStockParam=${14}
    export resultStrategieOverratedByPercentAndStochastic=""

    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
        if [ "$_lastStochasticQuoteRoundedParam" -gt "$_stochasticPercentageUpperParam" ] && [ "$_lastOverAgv18Param" = 1 ] && [ "$_lastOverAgv38Param" = 1 ] && [ "$_lastOverAgv95Param" = 1 ] && 
            [ "$_agv18OverAgv38Param" = 1 ] && [ "$_agv38OverAgv95Param" = 1 ] && [ "$_agv18OverAgv95Param" = 1 ]; then
            alarmAbbrevValue=P-$alarmAbbrevValue
            reasonPrefix="Sell: High Percent & Stochastic (P)"
            resultStrategieOverratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageLesserFactorParam over Avg18 > Avg38 > Avg95 and Stoch14 $_lastStochasticQuoteRoundedParam over level"
            echo "$resultStrategieOverratedByPercentAndStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedByPercentAndStochastic function:
# Strategie: Low Percent & Stochastic
# Input: ${x}
# Output: resultStrategieUnderratedByPercentAndStochastic
StrategieUnderratedByPercentAndStochastic() {
    _lastStochasticQuoteRoundedParam=$1
    _stochasticPercentageLowerParam=$2
    _lastUnderAgv18Param=$3
    _lastUnderAgv38Param=$4
    _lastUnderAgv95Param=$5
    _agv18UnderAgv38Param=$6
    _agv38UnderAgv95Param=$7
    _agv18UnderAgv95Param=$8
    _lastPriceParam=$9
    _percentageGreaterFactorParam=${10} # 10th and more need {}
    _outResultFileParam=${11}
    _symbolParam=${12}
    _symbolNameParam=${13}
    _markerOwnStockParam=${14}
    export resultStrategieUnderratedByPercentAndStochastic=""

    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ]; then # Check if value makes sense
        if [ "$_lastStochasticQuoteRoundedParam" -lt "$_stochasticPercentageLowerParam" ] && [ "$_lastUnderAgv18Param" = 1 ] && [ "$_lastUnderAgv38Param" = 1 ] && [ "$_lastUnderAgv95Param" = 1 ] && 
            [ "$_agv18UnderAgv38Param" = 1 ] && [ "$_agv38UnderAgv95Param" = 1 ] && [ "$_agv18UnderAgv95Param" = 1 ]; then
            alarmAbbrevValue=P+$alarmAbbrevValue
            reasonPrefix="Buy: Low Percent & Stochastic (P)"
            resultStrategieUnderratedByPercentAndStochastic="$reasonPrefix: $_lastPriceParam€ is $_percentageGreaterFactorParam under Avg18 < Avg38 < Avg95 and Stoch14 $_lastStochasticQuoteRoundedParam under level"
            echo "$resultStrategieUnderratedByPercentAndStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieOverratedXHighStochastic function:
# 4 last values over _highStochasticValueParam and one of the last is over?
# Strategie: High Stochastic X last values over highStochasticValue
# Input: ${x}
# Output: resultStrategieOverratedXHighStochastic
StrategieOverratedXHighStochastic() {  
    _highStochasticValueParam=$1
    _stochasticQuoteListParam=$2
    _outResultFileParam=$3
    _symbolParam=$4
    _symbolNameParam=$5
    _markerOwnStockParam=$6
    export resultStrategieOverratedXHighStochastic=""

    if [ "${#_stochasticQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Revers and output the last X numbers. Attention only works for SINGLE digst numbers!
        _stochasticQuoteListParam=$(echo "$_stochasticQuoteListParam" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteListParam"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteListParam
        # Cut comma, like: ",22" -> "22"        
        value1=$(echo "$1" | cut -b 2-3)
        value2=$(echo "$2" | cut -b 2-3)
        value3=$(echo "$3" | cut -b 2-3)
        value4=$(echo "$4" | cut -b 2-3)
        value5=$(echo "$5" | cut -b 2-3)
        value6=$(echo "$6" | cut -b 2-3)
        value7=$(echo "$7" | cut -b 2-3)

        # revsers digits '18' will be '81'
        value1=$(echo "$value1" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value2=$(echo "$value2" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value3=$(echo "$value3" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value4=$(echo "$value4" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value5=$(echo "$value5" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value6=$(echo "$value6" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        value7=$(echo "$value7" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}')
        IFS=$OLDIFS

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
        if [ "$value4" = '00' ]; then
            value4=99
        fi
        if [ "$value5" = '00' ]; then
            value5=99
        fi
        if [ "$value6" = '00' ]; then
            value6=99
        fi
        if [ "$value7" = '00' ]; then
            value7=99
        fi

        howManyOverHighStochasticValue=0
        oneOfTheLastStochasticHigh=0
        if [ "${#value1}" -gt 1 ] && [ "$value1" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
            oneOfTheLastStochasticHigh=1
        fi
        if [ "${#value2}" -gt 1 ] && [ "$value2" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
            oneOfTheLastStochasticHigh=1
        fi

        if [ "${#value3}" -gt 1 ] && [ "$value3" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi   
        if [ "${#value4}" -gt 1 ] && [ "$value4" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value5}" -gt 1 ] && [ "$value5" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value6}" -gt 1 ] && [ "$value6" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi
        if [ "${#value7}" -gt 1 ] && [ "$value7" -gt "$_highStochasticValueParam" ]; then
            howManyOverHighStochasticValue=$((howManyOverHighStochasticValue + 1))
        fi

        # 4 last values over _highStochasticValueParam and one of the last is over?
        if [ "$howManyOverHighStochasticValue" -ge 4 ] && [ "$oneOfTheLastStochasticHigh" = 1 ]; then
            alarmAbbrevValue=$howManyOverHighStochasticValue"S-"$alarmAbbrevValue
            reasonPrefix="Sell: High $howManyOverHighStochasticValue last Stochastic (S)"
            resultStrategieOverratedXHighStochastic="$reasonPrefix: $howManyOverHighStochasticValue last quotes over level"
            echo "$resultStrategieOverratedXHighStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedXLowStochastic function:
# 4 last values under _lowStochasticValueParam and one of the last is under?
# Strategie: Low Stochastic X last values under lowStochasticValue
# Input: ${x}
# Output: resultStrategieUnderratedXLowStochastic
StrategieUnderratedXLowStochastic() {
    _lowStochasticValueParam=$1
    _stochasticQuoteListParam=$2
    _outResultFileParam=$3
    _symbolParam=$4
    _symbolNameParam=$5
    _markerOwnStockParam=$6
    export resultStrategieUnderratedXLowStochastic=""

    if [ "${#_stochasticQuoteListParam}" -gt 1 ]; then # Check if value makes sense
        # Revers and output the last X numbers. Attention only works for single digst numbers!
        _stochasticQuoteListParam=$(echo "$_stochasticQuoteListParam" | awk '{ for(i = length; i!=0; i--) x = x substr($0, i, 1);} END {print x}' | awk -F',' '{ print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 }' )
        OLDIFS=$IFS
        # Warning do NOT quote this!! "$_stochasticQuoteListParam"
        # shellcheck disable=SC2086
        IFS="," set -- $_stochasticQuoteListParam
        # Cut comma, like: ",22" -> "22"
        value1=$(echo "$1" | cut -b 2-3)
        value2=$(echo "$2" | cut -b 2-3)
        value3=$(echo "$3" | cut -b 2-3)
        value4=$(echo "$4" | cut -b 2-3)
        value5=$(echo "$5" | cut -b 2-3)
        value6=$(echo "$6" | cut -b 2-3)
        value7=$(echo "$7" | cut -b 2-3)
        IFS=$OLDIFS
        howManyUnderLowStochasticValue=0
        oneOfTheLastStochasticLow=0
        # Check string length and low stochastic parameter
        if [ ! "${#value1}" -gt 1 ] && [ "$value1" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
            oneOfTheLastStochasticLow=1
        fi
        if [ ! "${#value2}" -gt 1 ] && [ "$value2" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
            oneOfTheLastStochasticLow=1
        fi

        if [ ! "${#value3}" -gt 1 ] && [ "$value3" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value4}" -gt 1 ] && [ "$value4" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value5}" -gt 1 ] && [ "$value5" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value6}" -gt 1 ] && [ "$value6" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi
        if [ ! "${#value7}" -gt 1 ] && [ "$value7" -lt "$_lowStochasticValueParam" ]; then
            howManyUnderLowStochasticValue=$((howManyUnderLowStochasticValue + 1))
        fi

        # 4 last values under _lowStochasticValueParam and one of the last is under?
        if [ "$howManyUnderLowStochasticValue" -ge 4 ] && [ "$oneOfTheLastStochasticLow" = 1 ]; then          
            alarmAbbrevValue=$howManyUnderLowStochasticValue"S+"$alarmAbbrevValue
            reasonPrefix="Buy: Low $howManyUnderLowStochasticValue last Stochastic (S)"
            resultStrategieUnderratedXLowStochastic="$reasonPrefix: $howManyUnderLowStochasticValue last quotes under level"
            echo "$resultStrategieUnderratedXLowStochastic"
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieOverratedHighStochasticHighRSIHighMACD function:
# Strategie: High Stochastic and High RSI last quote over highRSIValue and + MACD
# Input: ${x}
# Output: resultStrategieOverratedHighStochasticHighRSIHighMACD
StrategieOverratedHighStochasticHighRSIHighMACD() {
    _highStochasticValueParam=$1
    _highRSIQuoteParam=$2
    _lastStochasticQuoteRoundedParam=$3
    _lastRSIQuoteRoundedParam=$4
    _lastMACDValueParam=$5
    _outResultFileParam=$6
    _symbolParam=$7
    _symbolNameParam=$8
    _markerOwnStockParam=$9
    export resultStrategieOverratedHighStochasticHighRSIHighMACD=""

    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
        _lastMACDValueParamSign=$(echo "$_lastMACDValueParam" | awk '{print substr ($0, 0, 1)}')
        # Last Stochastic quote over _highStochasticValueParam and Last RSI quote over _highRSIValue and _lastMACDValueParam is positiv
        if [ "$_lastStochasticQuoteRoundedParam" -gt "$_highStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -gt "$_highRSIQuoteParam" ] && [ ! "$_lastMACDValueParamSign" = '-' ]; then
            alarmAbbrevValue=C-$alarmAbbrevValue
            reasonPrefix="Sell: High Stochastic & RSI & MACD+ (C)"
            resultStrategieOverratedHighStochasticHighRSIHighMACD="$reasonPrefix: Stochastic $_lastStochasticQuoteRoundedParam over level and RSI $_lastRSIQuoteRoundedParam over level"
            echo "$resultStrategieOverratedHighStochasticHighRSIHighMACD"                       
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$RED" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}

# StrategieUnderratedLowStochasticLowRSILowMACD function:
# Strategie: Low Stochastic and Low RSI last quote under lowRSIValue and - MACD
# Input: ${x}
# Output: resultStrategieLowStochasticUnderratedLowRSI
StrategieUnderratedLowStochasticLowRSILowMACD() {
    _lowStochasticValueParam=$1
    _lowRSIQuoteParam=$2
    _lastStochasticQuoteRoundedParam=$3
    _lastRSIQuoteRoundedParam=$4
    _lastMACDValueParam=$5
    _outResultFileParam=$6
    _symbolParam=$7
    _symbolNameParam=$8
    _markerOwnStockParam=$9
    export resultStrategieUnderratedLowStochasticLowRSILowMACD=""

    if [ "${#_lastStochasticQuoteRoundedParam}" -gt 0 ] && [ "${#_lastRSIQuoteRoundedParam}" -gt 0 ] && [ "${#_lastMACDValueParam}" -gt 0 ]; then # Check if value makes sense
        _lastMACDValueParamSign=$(echo "$_lastMACDValueParam" | awk '{print substr ($0, 0, 1)}')
        # Last Stochastic quote under _lowStochasticValueParam and Last RSI quote under _lowRSIValue and _lastMACDValueParam is negativ
        if [ "$_lastStochasticQuoteRoundedParam" -lt "$_lowStochasticValueParam" ] && [ "$_lastRSIQuoteRoundedParam" -lt "$_lowRSIQuoteParam" ] && [ "$_lastMACDValueParamSign" = '-' ]; then
            alarmAbbrevValue=C+$alarmAbbrevValue
            reasonPrefix="Buy: Low Stochastic & RSI & MACD- (C)"
            resultStrategieUnderratedLowStochasticLowRSILowMACD="$reasonPrefix: Stochastic $_lastStochasticQuoteRoundedParam under level and RSI $_lastRSIQuoteRoundedParam under level"
            echo "$resultStrategieUnderratedLowStochasticLowRSILowMACD"                       
            WriteComdirectUrlAndStoreFileList "$_outResultFileParam" "$_symbolParam" "$_symbolNameParam" "$GREEN" "$_markerOwnStockParam" "$reasonPrefix" "$lowMarketCapLinkBackgroundColor"
        fi
    fi
}
