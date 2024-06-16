#!/bin/bash

# Debug mode
#set -x

export alarmAbbrevTemplate="'','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99'"

# WriteOverallChartsButtons function: 
# Write javascript to result file
# Input: ${x}
# Output: -
WriteOverallChartsButtons() {
    _symbolsParam=$1
    _timeSpan=$2

    echo "<button id=\"intervalSectionButtonAll$_timeSpan\" style=\"font-size:large; height: 50px; width: 80px; display: none\" type=\"button\" onClick=\""
    for ownSymbol in $_symbolsParam
    do
        if [ "$(echo "$ownSymbol" | cut -b 1-1)" = '*' ]; then
            ownSymbol=$(echo "$ownSymbol" | cut -b 2-7)
            lineFromTickerFile=$(grep -m1 -P "$ownSymbol\t" "$TICKER_NAME_ID_FILE")
            notationId=$(echo "$lineFromTickerFile" | cut -f 3)
            echo "javascript:updateImage('$ownSymbol', '$notationId', '$_timeSpan');"
        fi
    done
    echo "\">$_timeSpan</button>" 
}

# WriteTransactionFile function: 
# Write buy/sell transaction to file in 'buy/sell' dir. E.g: buy/BEI.txt
# Keep history in file. E.g: buy/BEI_2021-02-09.txt
# Input: ${x}
# Output: buy/$symbol.txt file. E.g: buy/BEI.txt
WriteTransactionFile() {
    _lastDateInDataFile=$1
    _beforeLastDateInDataFile=$2
    _symbolParam=$3
    _transactionOutputDir=$4
    
    mkdir -p "$_transactionOutputDir"
    transactionSymbolLastDateFile=$_transactionOutputDir/$_symbolParam"_"$_lastDateInDataFile.txt 
    transactionSymbolBeforeLastDateFile=$_transactionOutputDir/$_symbolParam"_"$_beforeLastDateInDataFile.txt 

    if [ ! -f "$transactionSymbolLastDateFile" ]; then # Todays datefile doesn't exists e.g: buy/BEI_2021-02-09.txt
        if [ -f "$transactionSymbolBeforeLastDateFile" ]; then # Last datefile exists. Take the last datefile e.g: buy/BEI_2021-02-08.txt
            commaListTransaction=$(cut -d ' ' -f 2-90 < "$transactionSymbolBeforeLastDateFile")
            commaListTransaction="$commaListTransaction""{}, "
            echo "$commaListTransaction" > "$transactionSymbolLastDateFile"
            rm -rf "$transactionSymbolBeforeLastDateFile"
        else # Last datefile File doesn't exists. Create actual datefile from scratch e.g: buy/BEI_2021-02-09.txt
            rm -rf "$_transactionOutputDir"/"$_symbolParam"*.txt
            commaListTransaction="{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, "
            echo "$commaListTransaction" > "$transactionSymbolLastDateFile"
        fi
    fi
    cp -f "$transactionSymbolLastDateFile" "$_transactionOutputDir"/"$_symbolParam".txt  # Copy e.g: buy/BEI_2021-02-09.txt to buy/BEI.txt
}

# WriteAlarmAbbrevXAxisFile function: 
# Write the alarm x-axis file into 'alarm' dir. E.g: alarm/BEI.txt
# Keep history in file. E.g: alarm/BEI_2021-02-09.txt
# Input: ${x}
# Output: alarm/$symbol.txt file. E.g: alarm/BEI.txt
WriteAlarmAbbrevXAxisFile() {
    _newAlarmAbbrevTextParam=$1
    _symbolParam=$2
    _dataDateFile=$3
    _dataDateOutputDir=$4
    _markerOwnStockParam=$5 
    mkdir -p "$_dataDateOutputDir"
    lastDateInDataFile=$(head -n1 "$_dataDateFile" | cut -f 1)
    beforeLastDateInDataFile=$(head -n2 "$_dataDateFile" | tail -1 | cut -f 1)
    alarmSymbolFile=$_dataDateOutputDir/$_symbolParam.txt
    alarmSymbolLastDateFile=$_dataDateOutputDir/$_symbolParam"_"$lastDateInDataFile.txt 
    alarmSymbolBeforeLastDateFile=$_dataDateOutputDir/$_symbolParam"_"$beforeLastDateInDataFile.txt 
    
    lastDay=$(echo "$lastDateInDataFile" | cut -f 3 -d '-') # 2021-02-16 -> 16
    if [ "${#_newAlarmAbbrevTextParam}" -eq 0 ]; then
        _newAlarmAbbrevTextParam="$_markerOwnStockParam""$lastDay"
    else
        _newAlarmAbbrevTextParam="$_markerOwnStockParam""$_newAlarmAbbrevTextParam"
    fi

    if [ ! -f "$alarmSymbolLastDateFile" ]; then # Todays datefile doesn't exists e.g: alarm/BEI_2021-02-09.txt
        if [ -f "$alarmSymbolBeforeLastDateFile" ]; then # Last datefile exists. Take the last datefile e.g: alarm/BEI_2021-02-08.txt
            commaListAlarm=$(cut -d , -f 2-100 < "$alarmSymbolBeforeLastDateFile")
            commaListAlarm="$commaListAlarm,'$_newAlarmAbbrevTextParam'"
            echo "$commaListAlarm" > "$alarmSymbolLastDateFile"
            rm -rf "$alarmSymbolBeforeLastDateFile"
        else # Last datefile File doesn't exists. Create actual datefile from scratch e.g: alarm/BEI_2021-02-09.txt
            rm -rf "$_dataDateOutputDir"/"$_symbolParam"*.txt
#            alarmAbbrevTemplate="'','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99'"
            commaListAlarm="$alarmAbbrevTemplate,'$_newAlarmAbbrevTextParam'"
            echo "$commaListAlarm" > "$alarmSymbolLastDateFile"
        fi
    fi

    cp -f "$alarmSymbolLastDateFile" "$alarmSymbolFile" # Copy e.g: alarm/BEI_2021-02-09.txt to alarm/BEI.txt

    # Remove the first occurance of the alarms for a better Chart visiulization
    # '','*C+3R+4S+P+D+N+M+','*C+4R+4S+P+M+',.....
    alarmStringWithoutFristAlarm=$(cat "$alarmSymbolFile")
    alarmStringWithoutFristAlarm=${alarmStringWithoutFristAlarm#*,}
    alarmStringWithoutFristAlarm="'',$alarmStringWithoutFristAlarm"
    echo "$alarmStringWithoutFristAlarm" > "$alarmSymbolFile"    
}

# DetermineTendency function: 
# Tendency of the last 5 value of a comma seperated list of 87 values
# Input: ${x}
# Output: tendency [FALLING|RISING|LEVEL]
DetermineTendency() {
    _listParam=$1
    export tendency="$FALLING"

    value_82=$(echo "$_listParam" | cut -f 82 -d ',')
    value_87=$(echo "$_listParam" | cut -f 87 -d ',')  
    difference=$(echo "$value_87 $value_82" | awk '{print ($1 - $2)}')
    isNegativ=${difference:0:1}
    relative=$(echo "$value_87 $value_82" | awk '{print (($1 / $2)-1)*100}')
    valueBeforeComma=$(echo "$relative" | cut -f 1 -d '.')
    valueAfterComma=$(echo "$relative" | cut -f 2 -d '.')
    isLevelPos1=${valueAfterComma:0:1}
    if [ "$isLevelPos1" != "-" ]; then
        if [ "$isLevelPos1" -lt 2 ] && # < 0.02 %
        { [ "$valueBeforeComma" = "0" ] || [ "$valueBeforeComma" = "-0" ]; } then
            tendency="$LEVEL"
        else
            if [ "$isNegativ" = '-' ]; then
                tendency="$FALLING"
            else
                tendency="$RISING"
            fi
        fi
    fi    
}

# CurlSymbolName function: Curl and write Line to TICKER_NAME_ID_FILE
# Input: ${x}
# Output: -
CurlSymbolName() {
    _symbolParam=$1
    _tickerNameIdFileParam=$2
    _sleepParam=$3

    #symbol=$(echo "$_symbolParam" | tr '[:lower:]' '[:upper:]')
    symbolName=$(grep -m1 -P "$_symbolParam\t" "$_tickerNameIdFileParam" | cut -f 2)
    if [ ! "${#symbolName}" -gt 1 ]; then
        symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header "'$X_OPENFIGI_APIKEY'" --data '[{"idType":"TICKER", "idValue":"'"${_symbolParam}"'"}]' | jq '.[0].data[0].name')
        if ! [ "$symbolName" = 'null' ]; then
            echo "$_symbolParam""$(printf '\t')""$symbolName""$(printf '\t')""999999""$(printf '\t')""?""$(printf '\t')""\"--\"""$(printf '\t')""--""$(printf '\t')""--""$(printf '\t')""XETRA""$(printf '\t')""?""$(printf '\t')""STOCK""$(printf '\t')""\"---\"" | tee -a "$_tickerNameIdFileParam"
            tempTickerNameIdFile="$(mktemp -p "$TEMP_DIR")"
            sort -k 1 "$_tickerNameIdFileParam" > "$tempTickerNameIdFile"
            mv "$tempTickerNameIdFile" "$_tickerNameIdFileParam"
            # Can requested in bulk request as an option!
            sleep "$_sleepParam" # 14; Only reduced amount of requests per minute to "openfigi" (About 6 requests per minute).
        fi
    fi
}

# UsageCheckParameter function:
# Input: ${x}
# Output: OUT_RESULT_FILE
UsageCheckParameter() {
    _symbolsParam=$1
    _percentageParam=$2
    _queryParam=$3
    _stochasticPercentageParam=$4
    _RSIQuoteParam=$5
    _outResultFileParam=$6

    if  [ -n "${_symbolsParam##*[!a-zA-Z0-9* ]*}" ] && # symbols, blank and '*' allowed
        [ -n "${_percentageParam##*[!0-9]*}" ]  && 
        { [ "$_queryParam" = 'offline' ] || [ "$_queryParam" = 'online' ]; } &&
        [ -n "${_stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#_stochasticPercentageParam} -gt 1 ] &&
        [ -n "${_RSIQuoteParam##*[!0-9]*}" ] && [ ! "$_RSIQuoteParam" -gt 30 ]; then
        echo ""
    else
        echo "Given Parameter: Symbols=$_symbolsParam Persentage=$_percentageParam Query=$_queryParam Stoch=$_stochasticPercentageParam RSI=$_RSIQuoteParam"
        echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY STOCH RSI" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " PERCENTAGE: Percentage number between 0..100" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " QUERY: Query data online|offline" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " STOCHASTIC14: Percentage for stochastic indicator (only single digit allowed!)" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " RSI14: Quote for RSI indicator (only 30 and less allowed!)" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"    
        echo "Example: ./analyse.sh 'BEI ALV' 1 offline 9 25" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo "$HTML_RESULT_FILE_END" >> "$_outResultFileParam"
        exit 5
    fi
}

# LessThenWithFactor function:
# Input: ${x}
# Output: 1 if less
LessThenWithFactor() {
    _lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('"$_lesserValue"' < '"$3"')}'; then
        return 1
    else
        return 0        
    fi
}

# GreaterThenWithFactor function:
# Input: ${x}
# Output: 1 if 'factor'*'firstCompareValue'>'secondCompareValue' else 0
# Example 1.1*100>109 -> return 1
# Example 1.1*100>110 -> return 0
GreaterThenWithFactor() {
    _greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('"$_greaterValue"' > '"$3"')}'; then
        return 1
    else
        return 0
    fi
}

# ProgressBar function:
# Input: ${x}
# Output: echo
ProgressBar() {
    _currentStateParam=$1
    _totalStateParam=$2
    
    _progress_="$((_currentStateParam*10000/_totalStateParam))"
    _progress=$((_progress_/100))
    _done_=$((_progress*4))
    _done=$((_done_/10))
    _left=$((40-_done))
    # Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")                         
    # Progress: ######################################## 100%
    if [ ! "$(uname)" = 'Linux' ]; then
        # shellcheck disable=SC3037,SC3060
        echo -n "$(printf "\r${_fill// /#}${_empty// /-} ${_progress}%%")"
        if [ "$_currentStateParam" = "$_totalStateParam" ]; then
            echo ""
        fi
    fi
}

# WriteComdirectUrlAndStoreFileList function:
# Write Comdirect Url. Link can have 3 color: black (neutral), red (sell) and green (buy)
# Store list of files for later
# Input: ${x}
# Output: echo to file
WriteComdirectUrlAndStoreFileList() {
    _outResultFileParam=$1
    _symbolParam=$2
    _symbolNameParam="$3"
    _linkColorParam=$4
    _markerOwnStockParam=$5
    _reasonParam=$6
    _lowMarketCapBackgroundColorParam=$7

    # Red link only for stocks that are marked as own
    if [ "$_linkColorParam" = "$RED" ] && [ "$_markerOwnStockParam" = '' ]; then
        _linkColorParam="$BLACK"
    fi

    _id_notation=$(grep -m1 -P "$_symbolParam\t" "$TICKER_NAME_ID_FILE" | cut -f 3)
    if [ ! "${#_id_notation}" -gt 1 ]; then
        _id_notation=999999
    fi

#echo "---------------$_symbolParam $_id_notation"

    # Only write URL once into result file
    if [ ! "$_id_notation" = "$ID_NOTATION_STORE_FOR_NEXT_TIME" ]; then
#echo "++++++++++++++++$ID_NOTATION_STORE_FOR_NEXT_TIME"    
        ID_NOTATION_STORE_FOR_NEXT_TIME=$_id_notation
        {
            # Hover Chart (result overview page)
            #echo "<img class='imgborder' id='imgToReplace$_symbolParam' alt='' loading='lazy' style='display:none;position:fixed;top:40%;transform:scale(1.3);' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$_id_notation&TIME_SPAN=10D'/>"
            echo "<img class='imgborder' id='imgToReplace$_symbolParam' alt='' loading='lazy' style='display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$_id_notation&TIME_SPAN=10D'/>"
            echo "<div style='margin-top: 26px'>"
            echo "<a id='headlineLink$_symbolParam' style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('10D', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_PREFIX_10D$_id_notation' target='_blank'>$_markerOwnStockParam$_symbolParam $_symbolNameParam</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('6M', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_PREFIX_6M$_id_notation' target='_blank'>&nbsp;6M&nbsp;</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('5Y', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_PREFIX_5Y$_id_notation' target='_blank'>&nbsp;5Y&nbsp;</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$_symbolParam.html' target='_blank'>&nbsp;SA&nbsp;</a>"
            echo "<a id='linkPC$_symbolParam' style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam; display: none' href='D:/code/stock-analyse/out/$_symbolParam.html' target='_blank'>&nbsp;PC&nbsp;</a>"
            echo "</div>"
        } >> "$_outResultFileParam"
    fi
    # Show reason in result file only, if marked as own stock or a 'buy' recommendation
    if [ "$_markerOwnStockParam" = '*' ] || [ "$_linkColorParam" = "$GREEN" ]; then
        uniqueId=$(echo "$_symbolParam$_reasonParam" | tr -d '[:space:]')
        echo "<span id='detailsIdReason$uniqueId'>$_reasonParam<br></span>" >> "$_outResultFileParam"
    fi
}

# CreateCmdHyperlink function:
# Write file Hyperlink in CMD, Only works for windows
CreateCmdHyperlink() {
    _hyperlinkParam=$1
    _outDirParam=$2
    _symbolParam=$3

    _outputText="# $_hyperlinkParam $_symbolParam $symbolName"
    if [ "$(uname)" = 'Linux' ]; then
        echo "$_outputText"
    else
        _driveLetter=$(pwd | cut -f 2 -d '/')
        _suffix=$(pwd)
        # shellcheck disable=SC3057
        _suffixPath=${_suffix:2:200}
        _directory=$_driveLetter":"$_suffixPath
        # shellcheck disable=SC3037
        echo -e "\e]8;;file:///$_directory/$_outDirParam/$_symbolParam.html\a$_outputText\e]8;;\a"
    fi
}

# Out function:
# Write to console and file
Out() {
    _textParam=$1
    _outFileParam=$2

    echo -e "$_textParam" | tee -a "$_outFileParam"
    echo "<br>" >> "$_outFileParam"
}

# CalculateTxFee function:
# Input: Order rate
# Input: Pieces
# Output: trading fee
# 3.000 EUR Minimumprovision 7,12 EUR
# 5.000 EUR 0,25 % vom Kurswert EUR 10,00 EUR
# 10.000 EUR 0,25 % vom Kurswert 20,00 EUR
# 15.000 EUR 0,25 % vom Kurswert 30,00 EUR
# 25.000 EUR Maximalprovision 47,12 EUR
# Example 2500 -> return 7,12
# Example 3500 -> return 7,12
# Example 5100 -> return 10,00
# Example 10400 -> return 20,00
# Example 15500 -> return 30,00
# Example 40000 -> return 47,12
CalculateTxFee() {
    _orderrateParam=$1
    _piecesParam=$2

    export txFee="7"

    orderValue=$(echo "$_orderrateParam $_piecesParam" | awk '{print ($1 * $2)}')
    # Float to integer
    orderValue=${orderValue%.*}

    txFee="7"
    if [ "$orderValue" -gt 25000 ]; then 
        txFee="47"
    elif [ "$orderValue" -gt 15000 ]; then 
        txFee="30"
    elif [ "$orderValue" -gt 10000 ]; then 
        txFee="20"
    elif [ "$orderValue" -gt 5000 ]; then
        txFee="10"
    fi
}

# CalculateMarketCapRSILevel function:
# Input: RSI rate
# Input: Market Cap
# Output: true/false
# RSI=25 && MC < 100 -> true
# Example RSI=25 && MC < 100 -> return true
CalculateMarketCapRSILevel() {
    _lastRSIParam=$1
    _marketCapParam=$2

# sim CalculateMarketCapRSILevel
    if [ "$_marketCapParam" = "?" ]; then 
        _marketCapParam="10000"
    fi
# sim CalculateMarketCapRSILevel

    export isMarketCapRSILevel="false"

#echo _lastRSIParam "$_lastRSIParam" _marketCapParam "$_marketCapParam"

    isMarketCapRSILevel="false"
    if [ "$_lastRSIParam" -gt 24 ] && [ "$_marketCapParam" -gt 100 ]; then # > 25 RSI
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 24 ] && [ "$_marketCapParam" -gt 90 ]; then # = 24 RSI 
         isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 23 ] && [ "$_marketCapParam" -gt 80 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 22 ] && [ "$_marketCapParam" -gt 70 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 21 ] && [ "$_marketCapParam" -gt 60 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 20 ] && [ "$_marketCapParam" -gt 50 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 19 ] && [ "$_marketCapParam" -gt 40 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 18 ] && [ "$_marketCapParam" -gt 30 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 17 ] && [ "$_marketCapParam" -gt 20 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 16 ] && [ "$_marketCapParam" -gt 10 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -eq 15 ] && [ "$_marketCapParam" -gt 1 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -lt 15 ]; then 
        isMarketCapRSILevel="true"
    fi
}