#!/bin/sh

# CurlSymbolName function:
# Input is _symbolParam($1), _ticker_name_id_file_param($2), _sleepParam($3)
# Output: -
CurlSymbolName() {
    local _symbolParam=${1}
    local _ticker_name_id_file_param=${2}
    local _sleepParam=${3}
    symbol=$(echo "${_symbolParam}" | tr '[:lower:]' '[:upper:]')
    symbolName=$(grep -P "$symbol\t" "$_ticker_name_id_file_param" | cut -f 2)
    if [ ! "${#symbolName}" -gt 1 ]; then
        symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header "'$X_OPENFIGI_APIKEY'" --data '[{"idType":"TICKER", "idValue":"'"${_symbolParam}"'"}]' | jq '.[0].data[0].name')
#        symbolName=$(curl -s --location --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'"${_symbolParam}"'"}]' | jq '.[0].data[0].name')
        if ! [ "$symbolName" = 'null' ]; then
            echo "$_symbolParam""$(printf '\t')""$symbolName""$(printf '\t')""999999" | tee -a "$_ticker_name_id_file_param"
            local temp_ticker_name_id_file
            temp_ticker_name_id_file="$(mktemp -p /dev/shm/)"
            sort -k 1 "$_ticker_name_id_file_param" > "$temp_ticker_name_id_file"
            mv "$temp_ticker_name_id_file" "$_ticker_name_id_file_param"
            # Can requested in bulk request as an option!
            sleep "$_sleepParam" # 14; Only some requests per minute to openfigi (About 6 per minute).
        fi
    fi
}

# UsageCheckParameter function:
# Input is _symbolsParam($1), _percentageParam($2), _queryParam($3), _ratedParam($4), _stochasticPercentageParam($5), _RSIQuoteParam($6), OUT_RESULT_FILE_param($7)
# Output: OUT_RESULT_FILE
UsageCheckParameter() {
    local _symbolsParam=${1}
    local _percentageParam=${2}
    local _queryParam=${3}
    local _ratedParam=${4}
    local _stochasticPercentageParam=${5}
    local _RSIQuoteParam=${6}
    local OUT_RESULT_FILE_param=${7}

    if  [ -n "${_symbolsParam##*[!a-zA-Z0-9* ]*}" ] && # symbols, blank and '*' allowed
        [ -n "${_percentageParam##*[!0-9]*}" ]  && 
        { [ "$_queryParam" = 'offline' ] || [ "$_queryParam" = 'online' ]; } &&
        { [ "$_ratedParam" = 'overrated' ] || [ "$_ratedParam" = 'underrated' ] || [ "$_ratedParam" = 'all' ]; } &&
        [ -n "${_stochasticPercentageParam##*[!0-9]*}" ] && [ ! ${#_stochasticPercentageParam} -gt 1 ] &&
        [ -n "${_RSIQuoteParam##*[!0-9]*}" ] && [ ! "${_RSIQuoteParam}" -gt 30 ]; then
        echo ""
    else
        echo "Given Parameter: Symbols=$_symbolsParam Persentage=$_percentageParam Query=$_queryParam Rated=$_ratedParam Stoch=$_stochasticPercentageParam RSI=$_RSIQuoteParam"
        echo "Usage: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " SYMBOLS: Stock ticker symbols blank separated" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " PERCENTAGE: Percentage number between 0..100" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " QUERY: Query data online|offline" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " RATED: List stocks which are overrated|underrated|all" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " STOCHASTIC14: Percentage for stochastic indicator (only single digit allowed!)" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo " RSI14: Quote for RSI indicator (only 30 and less allowed!)" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"    
        echo "Example: ./analyse.sh 'ADS ALV' 3 offline underrated 9 30" | tee -a "$OUT_RESULT_FILE_param"
        echo "<br>" >> "$OUT_RESULT_FILE_param"
        echo "$HTML_RESULT_FILE_END" >> "$OUT_RESULT_FILE_param"
        exit 5
    fi
}

# LesserThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
# Output: 1 if lesser
LesserThenWithFactor() {
    local _lesserValue
    _lesserValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('"$_lesserValue"' < '"$3"')}'; then
        return 1
    else
        return 0        
    fi
}

# GreaterThenWithFactor function:
# Input is factor($1), firstCompareValue($2), secondCompareValue($3)
# Output: 1 if 'factor'*'firstCompareValue'>'secondCompareValue' else 0
# Example 1.1*100>109 -> return 1
# Example 1.1*100>110 -> return 0
GreaterThenWithFactor() {
    local _greaterValue
    _greaterValue=$(echo "$1 $2" | awk '{print $1 * $2}')
    if awk 'BEGIN {exit !('"$_greaterValue"' > '"$3"')}'; then
        return 1
    else
        return 0
    fi
}

# ProgressBar function:
# Input is currentStateParam($1) and totalStateParam($2)
# Output: echo
ProgressBar() {
    local currentStateParam=${1}
    local totalStateParam=${2}
    local _progress_="$((currentStateParam*10000/totalStateParam))"
    local _progress=$((_progress_/100))
    local _done_=$((_progress*4))
    local _done=$((_done_/10))
    local _left=$((40-_done))
    # Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")                         
    # Progress: ######################################## 100%
    if [ ! "$(uname)" = 'Linux' ]; then
        # shellcheck disable=SC3037,SC3060
        echo -n "$(printf "\r${_fill// /#}${_empty// /-} ${_progress}%%")"
        if [ "$currentStateParam" = "$totalStateParam" ]; then
            echo ""
        fi
    fi
}

# WriteComdirectUrlAndStoreFileList function:
# - Write Comdirect Url. Link can have 3 color: black (neutral), red (sell) and green (buy)
# - Store list of files for later (tar/zip)
# Input _out_result_file_param($1), _symbolParam($2), _symbolNameParam($3), _linkColorParam($4), _markerOwnStockParam($5), _reasonParam($6)
# Output: echo to file
WriteComdirectUrlAndStoreFileList() {
    local _out_result_file_param=${1}
    local _symbolParam=${2}
    local _symbolNameParam="${3}"
    local _linkColorParam=${4}
    local _markerOwnStockParam=${5}
    local _reasonParam=${6}
    local id_notation
    id_notation=$(grep -P "${symbol}\t" "$TICKER_ID_NAMES_FILE" | cut -f 3)
    if [ ! "${#id_notation}" -gt 1 ]; then
        id_notation=999999
    fi
    # Only write URL once into result file
    if [ ! "${id_notation}" = "${ID_NOTATION_STORE_FOR_NEXT_TIME}" ]; then
        ID_NOTATION_STORE_FOR_NEXT_TIME=$id_notation
        if [ "$_linkColorParam" = "red" ] || [ "$_linkColorParam" = "green" ]; then
            # Store list of files for later (tar/zip)
            # shellcheck disable=SC2116,SC2086
            reportedSymbolFileList=$(echo $reportedSymbolFileList out/${_symbolParam}.html)
        fi
        echo "<a style=color:$_linkColorParam href=""$COMDIRECT_URL_PREFIX"$id_notation " target=_blank>$_markerOwnStockParam$_symbolParam $_symbolNameParam</a><br>" >> "$_out_result_file_param"
    fi
    echo "$_reasonParam<br>" >> "$_out_result_file_param"
}

# CreateCmdAnalyseHyperlink function:
# - Write file Hyperlink in CMD, Only works for windows
CreateCmdAnalyseHyperlink() {
    local _outputText="# Analyse $symbol $symbolName"
    if [ "$(uname)" = 'Linux' ]; then
        echo "$_outputText"
    else
        local driveLetter
        driveLetter=$(pwd | cut -f 2 -d '/')
        local suffix
        suffix=$(pwd)
        # shellcheck disable=SC3057
        local suffixPath=${suffix:2:200}
        local directory=$driveLetter":"$suffixPath
        # shellcheck disable=SC3037
        echo -e "\e]8;;file:///""$directory""/out/""$symbol"".html\a$_outputText\e]8;;\a"
    fi
}
