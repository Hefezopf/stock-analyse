#!/bin/sh

# WriteAlarmAbbrevXAxisFile function: 
# Write the alarm x-axis file into 'alarm' dir. E.g: alarm/BEI.txt
# Keep history in datefile. E.g: alarm/BEI_2021-02-09.txt
# Input: ${x}
# Output: alarm/$symbol.txt file. E.g: alarm/BEI.txt
WriteAlarmAbbrevXAxisFile() {
    _newAlarmAbbrevTextParam=${1}
    _symbolParam=${2}
    _dataDateFile=${3}
    _dataDateOutputDir=${4}
    _markerOwnStockParam=${5}
    
    mkdir -p "$_dataDateOutputDir"
    lastDateInDataFile=$(head -n1 "$_dataDateFile" | cut -f 1)
    beforeDateInDataFile=$(head -n2 "$_dataDateFile" | tail -1 | cut -f 1)
    alarmSymbolFile=$_dataDateOutputDir/${_symbolParam}.txt
    alarmSymbolDateFile=$_dataDateOutputDir/${_symbolParam}_$lastDateInDataFile.txt 
    alarmSymbolDateBeforeFile=$_dataDateOutputDir/${_symbolParam}_$beforeDateInDataFile.txt 
    
    if [ "${#_newAlarmAbbrevTextParam}" -eq 0 ]; then
        lastDay=$(echo "$lastDateInDataFile" | cut -f 3 -d '-') # 2021-02-16 -> 16
        lastMonth=$(echo "$lastDateInDataFile" | cut -f 2 -d '-') # 2021-02-16 -> 02
        _newAlarmAbbrevTextParam=$(echo "$lastDay"-"$lastMonth")
    fi

    _newAlarmAbbrevTextParam="${_markerOwnStockParam}""$_newAlarmAbbrevTextParam"
    
    if [ ! -f "$alarmSymbolDateFile" ]; then # Todays datefile doesn't exists e.g: alarm/BEI_2021-02-09.txt
        if [ -f "$alarmSymbolDateBeforeFile" ]; then # Last datefile exists. Take the last datefile e.g: alarm/BEI_2021-02-08.txt
            commaListAlarm=$(cut -d , -f 2-100 < "$alarmSymbolDateBeforeFile")
            commaListAlarm="${commaListAlarm},'$_newAlarmAbbrevTextParam'"
            echo "$commaListAlarm" > "$alarmSymbolDateFile"
            rm -rf "$alarmSymbolDateBeforeFile"
        else # Last datefile File doesn't exists. Create actual datefile from scratch e.g: alarm/BEI_2021-02-09.txt
            rm -rf "$_dataDateOutputDir"/"${_symbolParam}"*.txt
            alarmAbbrevTemplate="'14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99'"
            commaListAlarm="$alarmAbbrevTemplate,'$_newAlarmAbbrevTextParam'"
            echo "$commaListAlarm" > "$alarmSymbolDateFile"
        fi
    fi
    cp -f "$alarmSymbolDateFile" "$alarmSymbolFile" # Copy e.g: alarm/BEI_2021-02-09.txt to alarm/BEI.txt
}

# DetermineTendency function: 
# Tendency of the last 5 value of a comma seperated list of 87 values
# Input: ${x}
# Output: tendency [FALLING|RISING|LEVEL]
DetermineTendency() {
    _listParam=${1}
    export tendency=""

    value_82=$(echo "$_listParam" | cut -f 82 -d ',')
    value_87=$(echo "$_listParam" | cut -f 87 -d ',')
    difference=$(echo "$value_87 $value_82" | awk '{print ($1 - $2)}')
    isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
    relative=$(echo "$value_87 $value_82" | awk '{print (($1 / $2)-1)*100}')
    valueBeforeComma=$(echo "$relative" | cut -f 1 -d '.')
    valueAfterComma=$(echo "$relative" | cut -f 2 -d '.')
    isLevelPos1=$(echo "${valueAfterComma}" | awk '{print substr ($0, 0, 1)}')

    if [ "${isLevelPos1}" -lt 2 ] && # < 0.02 %
       { [ "${valueBeforeComma}" = "0" ] || [ "${valueBeforeComma}" = "-0" ]; } then
        tendency="$LEVEL"
    else
        if [ "${isNegativ}" = '-' ]; then
            tendency="$FALLING"
        else
            tendency="$RISING"
        fi
    fi
}

# CurlSymbolName function:
# Input: ${x}
# Output: -
CurlSymbolName() {
    _symbolParam=${1}
    _tickerNameIdFileParam=${2}
    _sleepParam=${3}
    symbol=$(echo "${_symbolParam}" | tr '[:lower:]' '[:upper:]')
    symbolName=$(grep -m1 -P "$symbol\t" "$_tickerNameIdFileParam" | cut -f 2)
    if [ ! "${#symbolName}" -gt 1 ]; then
        symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header "'$X_OPENFIGI_APIKEY'" --data '[{"idType":"TICKER", "idValue":"'"${_symbolParam}"'"}]' | jq '.[0].data[0].name')
        if ! [ "$symbolName" = 'null' ]; then
            echo "$_symbolParam""$(printf '\t')""$symbolName""$(printf '\t')""999999" | tee -a "$_tickerNameIdFileParam"
            tempTickerNameIdFile="$(mktemp -p /dev/shm/)"
            sort -k 1 "$_tickerNameIdFileParam" > "$tempTickerNameIdFile"
            mv "$tempTickerNameIdFile" "$_tickerNameIdFileParam"
            # Can requested in bulk request as an option!
            sleep "$_sleepParam" # 14; Only some requests per minute to openfigi (About 6 per minute).
        fi
    fi
}

# UsageCheckParameter function:
# Input: ${x}
# Output: OUT_RESULT_FILE
UsageCheckParameter() {
    _symbolsParam=${1}
    _percentageParam=${2}
    _queryParam=${3}
    _stochasticPercentageParam=${4}
    _RSIQuoteParam=${5}
    _outResultFileParam=${6}
    if  [ -n "${_symbolsParam##*[!a-zA-Z0-9* ]*}" ] && # symbols, blank and '*' allowed
        [ -n "${_percentageParam##*[!0-9]*}" ]  && 
        { [ "$_queryParam" = 'offline' ] || [ "$_queryParam" = 'online' ]; } &&
        [ -n "${_stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#_stochasticPercentageParam} -gt 1 ] &&
        [ -n "${_RSIQuoteParam##*[!0-9]*}" ] && [ ! "${_RSIQuoteParam}" -gt 30 ]; then
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
        echo "Example: ./analyse.sh 'BEI ALV' 3 offline 9 30" | tee -a "$_outResultFileParam"
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
    _currentStateParam=${1}
    _totalStateParam=${2}
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
    _outResultFileParam=${1}
    _symbolParam=${2}
    _symbolNameParam="${3}"
    _linkColorParam=${4}
    _markerOwnStockParam=${5}
    _reasonParam=${6}

    # Red link only for stocks that are marked as own
    if [ "$_linkColorParam" = "$RED" ] && [ "${_markerOwnStockParam}" = '' ]; then
        _linkColorParam="$BLACK"
    fi

    _id_notation=$(grep -P "${symbol}\t" "$TICKER_NAME_ID_FILE" | cut -f 3)
    if [ ! "${#_id_notation}" -gt 1 ]; then
        _id_notation=999999
    fi
    # Only write URL once into result file
    if [ ! "${_id_notation}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
        ID_NOTATION_STORE_FOR_NEXT_TIME=$_id_notation
        {
            echo "<a class=\"$_linkColorParam\" href=\"$COMDIRECT_URL_PREFIX_6M$_id_notation\" target=\"_blank\">$_markerOwnStockParam$_symbolParam $_symbolNameParam</a> "
            echo "<a href=\"$COMDIRECT_URL_PREFIX_5Y$_id_notation\" target=\"_blank\">5Y</a>"
            echo "<a href=\"http://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$_symbolParam.html\" target=\"_blank\">SA</a>"
            echo "<a href=\"D:/code/stock-analyse/out/$_symbolParam.html\" target=\"_blank\">PC</a><br>"
        } >> "$_outResultFileParam"
    fi
    # Show reason in result file only, if marked as own stock or a 'buy' recommendation
    if [ "${_markerOwnStockParam}" = '*' ] || [ "$_linkColorParam" = "$GREEN" ]; then
        echo "$_reasonParam<br>" >> "$_outResultFileParam"
    fi
}

# CreateCmdAnalyseHyperlink function:
# Write file Hyperlink in CMD, Only works for windows
CreateCmdAnalyseHyperlink() {
    _outputText="# Analyse $symbol $symbolName"
    if [ "$(uname)" = 'Linux' ]; then
        echo "$_outputText"
    else
        _driveLetter=$(pwd | cut -f 2 -d '/')
        _suffix=$(pwd)
        # shellcheck disable=SC3057
        _suffixPath=${_suffix:2:200}
        _directory=$_driveLetter":"$_suffixPath
        # shellcheck disable=SC3037
        echo -e "\e]8;;file:///""$_directory""/out/""$symbol"".html\a$_outputText\e]8;;\a"
    fi
}
