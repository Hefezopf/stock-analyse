#!/bin/sh

# DetermineTendency function: 
# Tendency of the last 5 value of a comma seperated list
# Input: ${x}
# Output: tendency [FALLING|RISING|LEVEL]
DetermineTendency() {
    _list=${1}
    export tendency=""
    value_95=$(echo "$_list" | cut -f 95 -d ',')
    value_100=$(echo "$_list" | cut -f 100 -d ',')
    difference=$(echo "$value_100 $value_95" | awk '{print ($1 - $2)}')
    isNegativ=$(echo "${difference}" | awk '{print substr ($0, 0, 1)}')
    relative=$(echo "$value_100 $value_95" | awk '{print (($1 / $2)-1)*100}')
    valueBeforeComma=$(echo "$relative" | cut -f 1 -d '.')
    valueAfterComma=$(echo "$relative" | cut -f 2 -d '.')
    isLevelPos1=$(echo "${valueAfterComma}" | awk '{print substr ($0, 0, 1)}')

# echo _list "$_list"
# echo value_95 "$value_95" value_100 "$value_100"
# echo difference "$difference" 
# echo isNegativ "$isNegativ" 
# echo relative "$relative" 
# echo valueBeforeComma "$valueBeforeComma" valueAfterComma "$valueAfterComma" 
# echo isLevelPos1 "$isLevelPos1" 

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
        echo "Example: ./analyse.sh 'ADS ALV' 3 offline 9 30" | tee -a "$_outResultFileParam"
        echo "<br>" >> "$_outResultFileParam"
        echo "$HTML_RESULT_FILE_END" >> "$_outResultFileParam"
        exit 5
    fi
}

# LesserThenWithFactor function:
# Input: ${x}
# Output: 1 if lesser
LesserThenWithFactor() {
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
# Store list of files for later (tar/zip)
# Input: ${x}
# Output: echo to file
WriteComdirectUrlAndStoreFileList() {
    _outResultFileParam=${1}
    _symbolParam=${2}
    _symbolNameParam="${3}"
    _linkColorParam=${4}
    _markerOwnStockParam=${5}
    _reasonParam=${6}
    _id_notation=$(grep -P "${symbol}\t" "$TICKER_ID_NAMES_FILE" | cut -f 3)
    if [ ! "${#_id_notation}" -gt 1 ]; then
        _id_notation=999999
    fi
    
    # Only write URL once into result file
    if [ ! "${_id_notation}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
        ID_NOTATION_STORE_FOR_NEXT_TIME=$_id_notation
        if [ "$_linkColorParam" = "$RED" ] || [ "$_linkColorParam" = "$GREEN" ]; then
            # Store list of files for later (tar/zip)
            # shellcheck disable=SC2116,SC2086
            reportedSymbolFileList=$(echo $reportedSymbolFileList out/${_symbolParam}.html)
        fi
        echo "<a style=color:$_linkColorParam href=$COMDIRECT_URL_PREFIX$_id_notation target=_blank>$_markerOwnStockParam$_symbolParam $_symbolNameParam</a> " >> "$_outResultFileParam"
        echo "<a href=\"D:/code/stock-analyse/out/$_symbolParam.html\" target=_blank>&lt/&gt</a><br>" >> "$_outResultFileParam"
    fi
    # Show reason in result only, if marked as own stock or a 'buy' recommendation
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
