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
        if [ "${ownSymbol::1}" = '*' ]; then
        #if [ "$(echo "$ownSymbol" | cut -b 1-1)" = '*' ]; then #| cut -
            #ownSymbol=$(echo "$ownSymbol" | cut -b 2-7) #| cut -
            ownSymbol="${ownSymbol:1:7}"
            lineFromTickerFile=$(grep -m1 -P "$ownSymbol\t" "$TICKER_NAME_ID_FILE_MEM")
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
    _symbolParam=$2
    _transactionOutputDir=$3
 
    transactionSymbolLastDateFile=$_transactionOutputDir/$_symbolParam.txt 
    if [ ! -f "$transactionSymbolLastDateFile" ]; then
       commaListTransaction="{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, "
       echo "$commaListTransaction" > "$transactionSymbolLastDateFile"
    fi

    statusFile="$STATUS_DIR/$_symbolParam/$_symbolParam""_$_transactionOutputDir.txt"
    if [ ! -f "$statusFile" ]; then # Yesterdays statusFile doesn't exists e.g: status/BEI/BEI_buy.txt
        #touch "$statusFile"
        echo "$_lastDateInDataFile" > "$statusFile"
    fi

    statusDate=$(cat "$statusFile")
    if [ ! "$statusDate" = "$_lastDateInDataFile" ]; then
        echo "$_lastDateInDataFile" > "$statusFile"
        commaListTransaction=$(cut -f 2-90 -d ' ' < "$transactionSymbolLastDateFile")
        commaListTransaction="$commaListTransaction""{}, "
        echo "$commaListTransaction" > "$transactionSymbolLastDateFile"
    fi
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
    lastDateInDataFile=$(head -n1 "$_dataDateFile" | cut -f 1)
    alarmSymbolFile=$_dataDateOutputDir/$_symbolParam.txt
    
    lastDay=$(echo "$lastDateInDataFile" | cut -f 3 -d '-') # 2021-02-16 -> 16
    if [ "${#_newAlarmAbbrevTextParam}" -eq 0 ]; then
        _newAlarmAbbrevTextParam="$_markerOwnStockParam""$lastDay"
    else
        _newAlarmAbbrevTextParam="$_markerOwnStockParam""$_newAlarmAbbrevTextParam"
    fi

    if [ ! -f "$alarmSymbolFile" ]; then
       commaListAlarm="$alarmAbbrevTemplate,'$_newAlarmAbbrevTextParam'"
       echo "$commaListAlarm" > "$alarmSymbolFile"
    fi

    # shellcheck disable=SC2140
    statusFile="$STATUS_DIR/$_symbolParam/$_symbolParam"_"$_dataDateOutputDir.txt"
    if [ ! -f "$statusFile" ]; then # Yesterdays statusFile doesn't exists e.g: status/BEI/BEI_alarm.txt
        #touch "$statusFile"
        echo "$lastDateInDataFile" > "$statusFile"
    fi
    
    statusDate=$(cat "$statusFile")
    if [ ! "$statusDate" = "$lastDateInDataFile" ]; then
        echo "$lastDateInDataFile" > "$statusFile"
        commaListAlarm=$(cut -f 2-100 -d ',' < "$alarmSymbolFile")
        commaListAlarm="$commaListAlarm,'$_newAlarmAbbrevTextParam'"
        echo "$commaListAlarm" > "$alarmSymbolFile"
    fi

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

#echo "-------relative:$relative"    
    #valueBeforeComma=$(echo "$relative" | cut -f 1 -d '.')
     valueBeforeComma=${relative%*.*}
#echo "-------valueBeforeComma:$valueBeforeComma"

    #valueAfterComma=$(echo "$relative" | cut -f 2 -d '.')
     valueAfterComma=${relative#*.*}
#echo "-------valueAfterComma:$valueAfterComma"


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
    _symbolNameParam=$4

    symbolName="$_symbolNameParam"
#echo "-------0symbolName:$symbolName"
#echo "-------_tickerNameIdFileParam:$_tickerNameIdFileParam"    
#echo "symbolName=$symbolName --- _symbolNameParam=$_symbolNameParam"    
    #symbolName=$(grep -m1 -P "$_symbolParam\t" "$_tickerNameIdFileParam" | cut -f 2)
    if [ ! "${#symbolName}" -gt 1 ]; then
        symbolName=$(curl -c "'$COOKIES_FILE'" -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header "'$X_OPENFIGI_APIKEY'" --data '[{"idType":"TICKER", "idValue":"'"${_symbolParam}"'"}]' | jq '.[0].data[0].name')
#echo "-------1symbolName:$symbolName"         
        if ! [ "$symbolName" = 'null' ]; then
            echo "$_symbolParam""$(printf '\t')""$symbolName""$(printf '\t')""999999""$(printf '\t')""?""$(printf '\t')""\"--\"""$(printf '\t')""--""$(printf '\t')""--""$(printf '\t')""?""$(printf '\t')""STOCK""$(printf '\t')""\"---\"" | tee -a "$_tickerNameIdFileParam"
            tempTickerNameIdFile="$(mktemp -p "$TEMP_DIR")"
            sort -k 1 "$_tickerNameIdFileParam" > "$tempTickerNameIdFile"
#echo "-------sort tempTickerNameIdFile:$tempTickerNameIdFile"            
            mv "$tempTickerNameIdFile" "$_tickerNameIdFileParam"
            # Can requested in bulk request as an option!
            sleep "$_sleepParam" # 14; Only reduced amount of requests per minute to "openfigi" (About 6 requests per minute).
        fi
    fi
}

# UsageCheckParameter function:
# UsageCheckParameter "$symbolsParam" "$percentageParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE
# Input: ${x}
# Output: OUT_RESULT_FILE
UsageCheckParameter() {
    _symbolsParam=$1
    _percentageParam=$2
    #_queryParam=$3
    _stochasticPercentageParam=$3
    _RSIQuoteParam=$4
    _outResultFileParam=$5

    if  [ -n "${_symbolsParam##*[!a-zA-Z0-9* ]*}" ] && # symbols, blank and '*' allowed
        [ -n "${_percentageParam##*[!0-9]*}" ]  && 
     #   { [ "$_queryParam" = 'offline' ] || [ "$_queryParam" = 'online' ]; } &&
        [ -n "${_stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#_stochasticPercentageParam} -gt 1 ] &&
        [ -n "${_RSIQuoteParam##*[!0-9]*}" ] && [ ! "$_RSIQuoteParam" -gt 30 ]; then
        echo ""
    else
        echo "Given Parameter: Symbols=$_symbolsParam Percentage=$_percentageParam Stoch=$_stochasticPercentageParam RSI=$_RSIQuoteParam"
        echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE STOCH RSI" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " PERCENTAGE: Percentage number between 0..100" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
       # echo " QUERY: Query data online|offline" | tee -a "$_outResultFileParam"
       # echo "<br>" >> "$_outResultFileParam"
        echo " STOCHASTIC14: Percentage for stochastic indicator (only single digit allowed!)" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo " RSI14: Quote for RSI indicator (only 30 and less allowed!)" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo "Example: ./analyse.sh 'BEI ALV' 1 9 25" | tee -a "$_outResultFileParam"
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
    _pathParam="$8"

    # Red link only for stocks that are marked as own
    if [ "$_linkColorParam" = "$RED" ] && [ "$_markerOwnStockParam" = '' ]; then
        _linkColorParam="$BLACK"
    fi

    _id_notation=$(grep -m1 -P "$_symbolParam\t" "$TICKER_NAME_ID_FILE_MEM" | cut -f 3)
    if [ ! "${#_id_notation}" -gt 1 ]; then
        _id_notation=999999
    fi

    # Only write URL once into result file
    if [ ! "$_id_notation" = "$ID_NOTATION_STORE_FOR_NEXT_TIME" ]; then
        ID_NOTATION_STORE_FOR_NEXT_TIME=$_id_notation
        {
            # Hover Chart (result overview page)
            #echo "<img class='imgborder' id='imgToReplace$_symbolParam' alt='' loading='lazy' style='display:none;position:fixed;top:40%;transform:scale(1.3);' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$_id_notation&TIME_SPAN=10D'/>"
#            echo "<img class='imgborder' id='imgToReplace$_symbolParam' alt='' loading='lazy' style='display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$_id_notation&TIME_SPAN=10D'/>"
            echo "<img class='imgborder' id='imgToReplace$_symbolParam' alt='' loading='lazy' style='display:none;position:fixed;top:25%;left:20%;transform:scale(1.5);' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$_id_notation&TIME_SPAN=10D'/>"
            echo "<div style='font-size: xx-large; margin-top: 26px'>"
            COMDIRECT_URL_10D="$COMDIRECT_URL_STOCKS_PREFIX_10D"
            COMDIRECT_URL_6M="$COMDIRECT_URL_STOCKS_PREFIX_6M"
            COMDIRECT_URL_5Y="$COMDIRECT_URL_STOCKS_PREFIX_5Y"
            # shellcheck disable=SC2154
            if [ "$asset_type" = 'INDEX' ]; then
                COMDIRECT_URL_10D="$COMDIRECT_URL_INDEX_PREFIX_10D"
                COMDIRECT_URL_6M="$COMDIRECT_URL_INDEX_PREFIX_6M"
                COMDIRECT_URL_5Y="$COMDIRECT_URL_INDEX_PREFIX_5Y"
            fi
            echo "<a id='headlineLink$_symbolParam' style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('10D', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_10D$_id_notation' target='_blank'>$_markerOwnStockParam$_symbolParam $_symbolNameParam</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('6M', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_6M$_id_notation' target='_blank'>&nbsp;6M&nbsp;</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' onmouseover=\"javascript:showChart('5Y', '$_symbolParam')\" onmouseout=\"javascript:hideChart('$_symbolParam')\" href='$COMDIRECT_URL_5Y$_id_notation' target='_blank'>&nbsp;5Y&nbsp;</a>"
            echo "<a style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam' href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main$_pathParam/out/$_symbolParam.html' target='_blank'>&nbsp;SA&nbsp;</a>"
            echo "<a id='linkPC$_symbolParam' style='background:$_lowMarketCapBackgroundColorParam; color:$_linkColorParam; display: none' href='file:///D:/code/stock-analyse$_pathParam/out/$_symbolParam.html' target='_blank'>&nbsp;PC&nbsp;</a>"
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
# 3.000 EUR Minimumprovision 9,12 EUR
# 5.000 EUR 0,25 % vom Kurswert EUR 15,00 EUR
# 10.000 EUR 0,25 % vom Kurswert 20,00 EUR
# 15.000 EUR 0,25 % vom Kurswert 30,00 EUR
# 25.000 EUR Maximalprovision 47,12 EUR
# Example 2500 -> return 9,12
# Example 3500 -> return 9,12
# Example 5100 -> return 15,00
# Example 10400 -> return 20,00
# Example 15500 -> return 30,00
# Example 40000 -> return 47,12
CalculateTxFee() {
    _orderrateParam=$1
    _piecesParam=$2

    #export txFee="10"
    export txFee="1"

    orderValue=$(echo "$_orderrateParam $_piecesParam" | awk '{print ($1 * $2)}')
    # Float to integer
    orderValue=${orderValue%.*}

    txFee="10"
    if [ "$orderValue" -gt 25000 ]; then 
        txFee="47"
    elif [ "$orderValue" -gt 15000 ]; then 
        txFee="30"
    elif [ "$orderValue" -gt 10000 ]; then 
        txFee="20"
    elif [ "$orderValue" -gt 5000 ]; then
        txFee="15"
    fi
    txFee="1"
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
        _marketCapParam="1"
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
    elif [ "$_lastRSIParam" -lt 16 ] && [ "$_marketCapParam" -gt 1 ]; then 
        isMarketCapRSILevel="true"
    elif [ "$_lastRSIParam" -lt 16 ]; then 
        isMarketCapRSILevel="true"
    fi
}

# GetCreationDate function:
# Example 29-Apr-2021 08:52
GetCreationDate() {
    export creationDate

    creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
    if [ "$(uname)" = 'Linux' ]; then
        #creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # Sommerzeit / Summertime 
        creationDate=$(TZ=EST-0EDT date +"%e-%b-%Y %R") # Winterzeit / Wintertime
    fi
}