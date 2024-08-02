#!/bin/bash

# This script checks given stock quotes and their averages of the last 95, 38, 18 days.
# Stochastic, RSI and MACD are calculated as well
# Call: . analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 4. Parameter: RSI: Quote for RSI indicator (only 30 and less allowed!)
# Call example: . analyse.sh 'BEI ALV' 1 9 25
# Call example: . analyse.sh 'BEI' 2 9 25
# Call example: . analyse.sh 'BEI' 1 9 25
# Precondition:
# Set MARKET_STACK_ACCESS_KEY as ENV Variable (Online)
# Set GPG_PASSPHRASE as ENV Variable

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh
. script/averages.sh
. script/strategies.sh

# Switches for calculating charts and underlying strategies. Default is 'true'
# 6th parameter is undocumented! Speeds up development!
if { [ -z "$5" ]; } then
    CalculateStochastic=true
    CalculateRSI=true
    CalculateMACD=true
else
    CalculateStochastic=false
    CalculateRSI=false
    CalculateMACD=false
fi

# Switches to turn on/off Strategies. Default is 'true'
ApplyStrategieByTendency=false
ApplyStrategieHorizontalMACD=true

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

#export MARKET_STACK_ACCESS_KEY

# Parameter
symbolsParam=$1
percentageParam=$2
#queryParam=$3
stochasticPercentageParam=$3
RSIQuoteParam=$4

# Prepare
lowestRSI=100
counterOwnStocks=0 # For Spinner
rm -rf "$TEMP_DIR"/tmp.*
mkdir -p "$STATUS_DIR"
mkdir -p sell
mkdir -p buy
mkdir -p alarm
mkdir -p out
mkdir -p temp
cp template/favicon.ico out
cp template/_result.css out
cp template/_result.js out
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null
alarmAbbrevValue=""
HTML_RESULT_FILE_HEADER="<!DOCTYPE html><html lang='en'>
<head>
<meta charset='utf-8' />
<meta http-equiv='cache-control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='pragma' content='no-cache' />
<meta http-equiv='expires' content='0' />
<link rel='shortcut icon' type='image/ico' href='favicon.ico' />
<link rel='stylesheet' href='_result.css'>
<script type='text/javascript' src='_result.js'></script>
<title>Result SA</title>
</head>
<body>
<div id='symbolsListId'>"
echo "$HTML_RESULT_FILE_HEADER" > $OUT_RESULT_FILE
creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
if [ "$(uname)" = 'Linux' ]; then
   # creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # +2h Winterzeit / Wintertime
    #creationDate=$(TZ=EST-0EDT date +"%e-%b-%Y %R") # +1h Sommerzeit / Summertime
    creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") #  Sommerzeit / Summertime
fi
GOOD_LUCK="<p style='text-align: left; padding-right: 50px'>Good Luck! <a href='https://www.paypal.com/donate/?hosted_button_id=G2CERK22Q4QP8' target='_blank'>Donate?</a> $creationDate</p>"
HTML_RESULT_FILE_END="$GOOD_LUCK<br></div>
<!-- <script type='text/javascript' src='_result.js'></script> -->
</body></html>"
START_TIME_MEASUREMENT=$(date +%s);

# Check for multiple identical symbols in cmd. Do not ignore '*' 
if echo "$symbolsParam" | tr -d '*' | tr '[:lower:]' '[:upper:]' | tr " " "\n" | sort | uniq -c | grep -v '^ *1 '; then
    echo "WARNING: Multiple symbols in parameter list!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" "$percentageParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE

if [ ! "$CalculateStochastic" = true ] || [ ! "$CalculateRSI" = true ] || [ ! "$CalculateMACD" = true ]; then
    echo "WARNING: CalculateStochastic or CalculateRSI or CalculateMACD NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
    ApplyStrategieHorizontalMACD=false
fi

if { [ -z "$GPG_PASSPHRASE" ]; } then
    echo "Error GPG_PASSPHRASE NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 6
fi

#percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageLesserFactor=$(echo "scale=2;(100+$percentageParam)/100" | bc)
#percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')
percentageGreaterFactor=$(echo "scale=2;(100-$percentageParam)/100" | bc)

# RSI percentage
RSIQuoteLower=$RSIQuoteParam
RSIQuoteUpper=$((100-RSIQuoteParam))

# Stochastics percentage
stochasticPercentageLower=$stochasticPercentageParam
stochasticPercentageUpper=$((100-stochasticPercentageParam))

# Spinner
echo "<div id='spinner' style='display: X' class='loader'></div>" >> $OUT_RESULT_FILE
echo "<span id='parameterId'>" >> $OUT_RESULT_FILE
Out "# SA Analyse" $OUT_RESULT_FILE
Out "###########" $OUT_RESULT_FILE
Out "" $OUT_RESULT_FILE
echo "# Parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage:$percentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic:$stochasticPercentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI:$RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "</span>" >> $OUT_RESULT_FILE
{
    echo "<span id='analyseId'><br><br># Analyse<br></span>"
    echo "<br><span id='intervalSectionHeadlineDaily' style='display: none'># Realtime difference to previous day</span><br>"
    echo "<span id='obfuscatedValueBuyingDailyRealtime' style='font-size:xx-large; display: none'>---</span><br><br>"
    echo "<button id='intervalSectionButtonSortDaily' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doSortDailyGain()'>&nbsp;&nbsp;Daily&nbsp;%</button>&nbsp;"
    echo "<button id='intervalSectionButtonSortValue' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doSortInvestedValue()'>&nbsp;&nbsp;Value&nbsp;€</button>&nbsp;"
    echo "<button id='intervalSectionButtonSortOverall' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doSortOverallGain()'>&nbsp;&nbsp;&sum;&nbsp;%</button>&nbsp;"
    echo "<button id='intervalSectionButtonHideDetails' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doHideDetails()'>&nbsp;&nbsp;Details</button>"
    echo "<button id='intervalSectionButtonGoToEnd' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doGoToEnd()'>GoTo End</button>&nbsp;"
    echo "<button id='intervalSectionButtonOpenAll' style='font-size:large; height: 60px; width: 118px; display: none' disabled='disabled' type='button' onClick='javascript:doOpenAllInTab()'>Open All</button>"
    echo "<hr id='intervalSectionHROverallButtons' style='display: none'>"
} >> "$OUT_RESULT_FILE"

# Analyse stock data for each symbol
for symbol in $symbolsParam
do
    # Stocks with prefix '*' are marked as own stocks
    markerOwnStock=""
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        markerOwnStock="*"
        symbol=$(echo "$symbol" | cut -b 2-7)
    fi

    #symbol=$(echo "$symbol" | tr '[:lower:]' '[:upper:]')
    symbol="${symbol^^}" # all uppercase

    if [ ! -f "status/$symbol/$symbol""_alarm.txt" ]; then # For new symbols only
        mkdir -p status/"$symbol"
    fi

    echo "<div id='symbolLineId$symbol'>" >> $OUT_RESULT_FILE # Sorting

    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
    # Curl and write Line to TICKER_NAME_ID_FILE. When new symbols: Delay of 14 seconds because of REST API restrictions.
    # Only reduced amount of requests per minute to "openfigi" (About 6 requests per minute).
    CurlSymbolName "$symbol" "$TICKER_NAME_ID_FILE" 14 "$symbolName"

    hauptversammlung=$(echo "$lineFromTickerFile" | cut -f 8)
    if [ ! "$hauptversammlung" ]; then # Default: hauptversammlung="?"
        hauptversammlung="?"
    fi
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    if [ ! "$asset_type" ]; then # Default: asset_type="?"
        asset_type="?"
    fi
    
    # Get stock data
    echo ""
    echo "# Get $symbol $symbolName"
    DATA_FILE="$(mktemp -p "$TEMP_DIR")"
    DATA_DATE_FILE="$DATA_DIR/$symbol.txt"

    CreateCmdHyperlink "Analyse" "out" "$symbol" #"$symbolName"

    # Check, if 100 last quotes are availible, otherwise fill up to 100 
    numOfQuotes=$(grep "" -F -c "$DATA_DATE_FILE")
    if [ "$numOfQuotes" -lt 100 ]; then
        echo "<br>" >> $OUT_RESULT_FILE
        echo "!!! LESS then 100 quotes for $symbol" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
        lastQuoteInFile=$(tail -1 "$DATA_DATE_FILE" | cut -f 2)
        numOfQuotesToAdd=$((100 - numOfQuotes))
        indexWhile=0
        while [ "$indexWhile" -lt "$numOfQuotesToAdd" ]; do
            echo "9999-99-99	$lastQuoteInFile" >> "$DATA_DATE_FILE"
            indexWhile=$((indexWhile + 1))
        done
    fi

    awk '{print $2}' "$DATA_DATE_FILE" > "$DATA_FILE"
    lastRaw=$(head -n1 "$DATA_FILE")
    last=$(printf "%.2f" "$lastRaw")
    # Check for unknown symbols or not fetched symbols in cmd or on marketstack.com
    if [ "${#lastRaw}" -eq 0 ]; then
        echo "<br>" >> $OUT_RESULT_FILE
        echo "!!! $symbol NOT found in $DATA_DIR/$symbol.txt" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
        # Continue with next symbol in the list
        continue
    fi
    
    ProgressBar 1 8

    # Calculate MACD 12, 26 values
    if [ "$CalculateMACD" = true ]; then
        # EMAverage 12
        averagePriceList=""
        QUOTES_AS_ARRAY=("$(cat "$DATA_FILE")")
        EMAverageOfDays 12 "$DATA_FILE" "${QUOTES_AS_ARRAY[@]}"
        averagePriceList12=$averagePriceList
        # EMAverage 26
        averagePriceList=""
        EMAverageOfDays 26 "$DATA_FILE" "${QUOTES_AS_ARRAY[@]}"
        averagePriceList26=$averagePriceList
        # MACD
        lastMACDValue=0
        MACDList=""
        MACD_12_26 "$averagePriceList12" "$averagePriceList26"
    fi

    average18Raw=$(head -n18 "$DATA_FILE" | awk '{sum += $1;} END {print sum/18;}')
    average18=$(printf "%.2f" "$average18Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average18"; lastOverAgv18=$?
    LessThenWithFactor "$percentageLesserFactor" "$last" "$average18"; lastUnderAgv18=$?

    ProgressBar 2 8

    average38Raw=$(head -n38 "$DATA_FILE" | awk '{sum += $1;} END {print sum/38;}')
    average38=$(printf "%.2f" "$average38Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average38"; lastOverAgv38=$?
    LessThenWithFactor "$percentageLesserFactor" "$last" "$average38"; lastUnderAgv38=$?

    average95Raw=$(head -n95 "$DATA_FILE" | awk '{sum += $1;} END {print sum/95;}')
    average95=$(printf "%.2f" "$average95Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average95"; lastOverAgv95=$?
    LessThenWithFactor "$percentageLesserFactor" "$last" "$average95"; lastUnderAgv95=$?

    # Percentage on averages
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average38"; agv18OverAgv38=$?
    LessThenWithFactor "$percentageLesserFactor" "$average18" "$average38"; agv18UnderAgv38=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average38" "$average95"; agv38OverAgv95=$?
    LessThenWithFactor "$percentageLesserFactor" "$average38" "$average95"; agv38UnderAgv95=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average95"; agv18OverAgv95=$?
    LessThenWithFactor "$percentageLesserFactor" "$average18" "$average95"; agv18UnderAgv95=$?

    ProgressBar 3 8

    # Calculate RSI 14 values
    lastRSIQuoteRounded=0
    beforeLastRSIQuoteRounded=0
    RSIQuoteList=""
    if [ "$CalculateRSI" = true ]; then
        RSIOfDays 14 "$DATA_FILE"
    fi

    ProgressBar 4 8

    # Calculate Stochastic 14 values
    lastStochasticQuoteRounded=0
    stochasticQuoteList=""
    if [ "$CalculateStochastic" = true ]; then
        StochasticOfDays 14 "$DATA_FILE"
    fi

    ProgressBar 5 8

    # Average 18
    averageInDays18=18
    averagePriceList=""
    AverageOfDays $averageInDays18 "$DATA_FILE"
    averagePriceList18=$averagePriceList

    ProgressBar 6 8

    # Average 38
    averageInDays38=38
    averagePriceList=""
    AverageOfDays $averageInDays38 "$DATA_FILE"
    averagePriceList38=$averagePriceList

    ProgressBar 7 8

    # Average 95
    averageInDays95=95
    averagePriceList=""
    AverageOfDays $averageInDays95 "$DATA_FILE"
    averagePriceList95=$averagePriceList

    tendency18=""
    DetermineTendency "$averagePriceList18"
    # shellcheck disable=SC2154
    tendency18="$tendency"

    tendency38=""
    DetermineTendency "$averagePriceList38"
    tendency38="$tendency"

    ProgressBar 8 8
    
    #
    # Apply strategies
    #

    # Valid data is more then 200kb. Oherwise data might be damaged or unsufficiant
    fileSize=$(stat -c %s "$DATA_FILE")
    if [ "$fileSize" -gt 200 ]; then

        # Market Cap
        marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
        lowMarketCapLinkBackgroundColor="white"
        if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
            lowMarketCapLinkBackgroundColor="rgba(251, 225, 173)" # "rgba(244,164,80,255)"
        fi

        # Strategie: Quote by Tendency
        if [ "$ApplyStrategieByTendency" = true ]; then
            resultStrategieByTendency=""
            StrategieByTendency "$last" "$tendency38" "$percentageLesserFactor" "$average95" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
        fi

        # Buy Strategie: Low horizontal MACD
        if [ "$ApplyStrategieHorizontalMACD" = true ]; then
            resultStrategieUnderratedLowHorizontalMACD=""
            StrategieUnderratedLowHorizontalMACD "$MACDList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
        fi

        # Buy Strategie: New Low
        DATA_FILE_87="$(mktemp -p "$TEMP_DIR")"
        head -n87 "$DATA_FILE" > "$DATA_FILE_87"
        commaPriceList=$(awk '{ print $1","; }' < "$DATA_FILE_87" | tac)
        beforeLastQuote=$(head -n2 "$DATA_FILE" | tail -1)
        beforeLastQuote=$(printf "%.2f" "$beforeLastQuote")
        resultStrategieUnderratedNewLow=""
        conditionNewLow=false
        StrategieUnderratedNewLow 40 "$commaPriceList" "$last" "$beforeLastQuote" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Buy Strategie: Divergence RSI
        resultStrategieUnderratedDivergenceRSI=""
        StrategieUnderratedDivergenceRSI "$RSIQuoteLower" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock" "$lastMACDValue" "$last" "$beforeLastQuote" "$lastRSIQuoteRounded" "$lowestRSI" "$conditionNewLow"

        # Buy Strategie: Low Percentage & Stochastic
        resultStrategieUnderratedByPercentAndStochastic=""
        StrategieUnderratedByPercentAndStochastic "$lastStochasticQuoteRounded" "$stochasticPercentageLower" "$lastUnderAgv18" "$lastUnderAgv38" "$lastUnderAgv95" "$agv18UnderAgv38" "$agv38UnderAgv95" "$agv18UnderAgv95" "$last" "$percentageGreaterFactor" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
    
        # Buy Strategie: Low Stochastic X last values under lowStochasticValue
        resultStrategieUnderratedXLowStochastic=""
        StrategieUnderratedXLowStochastic "$stochasticPercentageLower" "$stochasticQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Buy Strategie: Low RSI X last values under RSIQuoteLower
        resultStrategieUnderratedXLowRSI=""
        StrategieUnderratedXLowRSI "$RSIQuoteLower" "$RSIQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Buy Strategie: Low stochastic and Low RSI last quote under stochasticPercentageLower and RSIQuoteLower
        resultStrategieUnderratedLowStochasticLowRSILowMACD=""
        StrategieUnderratedLowStochasticLowRSILowMACD "$stochasticPercentageLower" "$RSIQuoteLower" "$lastStochasticQuoteRounded" "$lastRSIQuoteRounded" "$lastMACDValue" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Sell Strategie: High horizontal MACD
        if [ "$ApplyStrategieHorizontalMACD" = true ]; then
            resultStrategieOverratedHighHorizontalMACD=""
            StrategieOverratedHighHorizontalMACD "$MACDList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
        fi

        # Sell Strategie: Stochastic When Own
        resultStrategieOverratedStochasticWhenOwn=""
        StrategieOverratedStochasticWhenOwn "$stochasticPercentageUpper" "$lastStochasticQuoteRounded" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Sell Strategie: Divergence RSI
        resultStrategieOverratedDivergenceRSI=""
        StrategieOverratedDivergenceRSI "$RSIQuoteUpper" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock" "$lastMACDValue" "$last" "$beforeLastQuote" "$lastRSIQuoteRounded" "$beforeLastRSIQuoteRounded"

        # Sell Strategie: High Percentage & Stochastic
        resultStrategieOverratedByPercentAndStochastic=""
        StrategieOverratedByPercentAndStochastic "$lastStochasticQuoteRounded" "$stochasticPercentageUpper" "$lastOverAgv18" "$lastOverAgv38" "$lastOverAgv95" "$agv18OverAgv38" "$agv38OverAgv95" "$agv18OverAgv95" "$last" "$percentageLesserFactor" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Sell Strategie: High Stochastic X last values over highStochasticValue
        resultStrategieOverratedXHighStochastic=""
        StrategieOverratedXHighStochastic "$stochasticPercentageUpper" "$stochasticQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Sell Strategie: High RSI X last values over RSIQuoteUpper
        resultStrategieOverratedXHighRSI=""
        StrategieOverratedXHighRSI "$RSIQuoteUpper" "$RSIQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Sell Strategie: High stochastic and High RSI last quote over stochasticPercentageUpper and RSIQuoteUpper
        resultStrategieOverratedHighStochasticHighRSIHighMACD=""
        StrategieOverratedHighStochasticHighRSIHighMACD "$stochasticPercentageUpper" "$RSIQuoteUpper" "$lastStochasticQuoteRounded" "$lastRSIQuoteRounded" "$lastMACDValue" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
    else
        echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
    fi

    #
    # Write Chart
    #
    indexSymbolFile=out/$symbol.html
    rm -rf "$indexSymbolFile"
    {
        cat template/indexPart0.html
        echo "$markerOwnStock$symbol"
        cat template/indexPart1.html

        # Color result link in Chart
        styleComdirectLink="style=\"font-size:50px; color:black\""
        # Red link only for stocks that are marked as own stocks
        if [ "$markerOwnStock" = '*' ] &&
           {
            [ "$(echo "$resultStrategieByTendency" | cut -f 1 -d ':')" = "Sell" ] ||
            [ "${#resultStrategieOverratedStochasticWhenOwn}" -gt 1 ] ||
            [ "${#resultStrategieOverratedDivergenceRSI}" -gt 1 ] ||
            [ "${#resultStrategieOverratedHighHorizontalMACD}" -gt 1 ] || [ "${#resultStrategieOverratedByPercentAndStochastic}" -gt 1 ] ||
            [ "${#resultStrategieOverratedXHighStochastic}" -gt 1 ] || [ "${#resultStrategieOverratedXHighRSI}" -gt 1 ] ||
            [ "${#resultStrategieOverratedHighStochasticHighRSIHighMACD}" -gt 1 ]; } then
            styleComdirectLink="style=\"font-size:50px; color:red\""
        fi

        if 
           [ "$(echo "$resultStrategieByTendency" | cut -f 1 -d ':')" = "Buy" ] ||
           [ "${#resultStrategieUnderratedNewLow}" -gt 1 ] || 
           [ "${#resultStrategieUnderratedDivergenceRSI}" -gt 1 ] || 
           [ "${#resultStrategieUnderratedLowHorizontalMACD}" -gt 1 ] || [ "${#resultStrategieUnderratedByPercentAndStochastic}" -gt 1 ] ||
           [ "${#resultStrategieUnderratedXLowStochastic}" -gt 1 ] || [ "${#resultStrategieUnderratedXLowRSI}" -gt 1 ] ||
           [ "${#resultStrategieUnderratedLowStochasticLowRSILowMACD}" -gt 1 ]; then
            styleComdirectLink="style=\"font-size:50px; color:green\""
        fi

        ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)

        # Hover Chart (on detail/dedicated symbol page)

        # Hier muss unterschieden werden, ob Mobil oder PC-Browser!
        # Mobil
        #echo "<img class='imgborder' id='imgToReplace' alt='' loading='lazy' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$ID_NOTATION&TIME_SPAN=10D' style='display:none;position:fixed;top:41%;left:27%;transform:scale(1.6,1.6);'/>"
        # PC-Browser
        echo "<img class='imgborder' id='imgToReplace' alt='' loading='lazy' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$ID_NOTATION&TIME_SPAN=10D' style='display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);'/>"
       
        COMDIRECT_URL_10D="$COMDIRECT_URL_STOCKS_PREFIX_10D"
        COMDIRECT_URL_6M="$COMDIRECT_URL_STOCKS_PREFIX_6M"
        COMDIRECT_URL_5Y="$COMDIRECT_URL_STOCKS_PREFIX_5Y"
        if [ "$asset_type" = 'INDEX' ]; then
            COMDIRECT_URL_10D="$COMDIRECT_URL_INDEX_PREFIX_10D"
            COMDIRECT_URL_6M="$COMDIRECT_URL_INDEX_PREFIX_6M"
            COMDIRECT_URL_5Y="$COMDIRECT_URL_INDEX_PREFIX_5Y"
        fi
        echo "<p style='text-align:right'><a $styleComdirectLink onmouseover=\"javascript:showChart('10D')\" onmouseout='javascript:hideChart()' href=\"$COMDIRECT_URL_10D""$ID_NOTATION"\" " target=\"_blank\">$markerOwnStock$symbol $symbolName</a>"
        echo "<a $styleComdirectLink onmouseover=\"javascript:showChart('6M')\" onmouseout='javascript:hideChart()' href=\"$COMDIRECT_URL_6M""$ID_NOTATION"\" " target=\"_blank\">&nbsp;6M&nbsp;</a>"
        echo "<a $styleComdirectLink onmouseover=\"javascript:showChart('5Y')\" onmouseout='javascript:hideChart()' href=\"$COMDIRECT_URL_5Y""$ID_NOTATION"\" " target=\"_blank\">&nbsp;5Y&nbsp;</a>"

        echo "&nbsp;&nbsp;<span style='font-size:50px; color:rgb(0, 0, 0)'><b>$last€</b></span>"

        percentLastDay=$(echo "$last $beforeLastQuote" | awk '{print ((($1 / $2)-1)*100)}')
        percentLastDay=$(printf "%.1f" "$percentLastDay")
        isNegativ=${percentLastDay:0:1}
        _linkColor="$GREEN"
        if [ "$isNegativ" = '-' ]; then
            _linkColor="$RED"
        fi

        echo "&nbsp;<span style='font-size:50px; color:$_linkColor'><b>""$percentLastDay""%</b></span></p>" 
        
        cat template/indexPart1a.html

        WriteAlarmAbbrevXAxisFile "$alarmAbbrevValue" "$symbol" "$DATA_DATE_FILE" "alarm" "$markerOwnStock"
        alarmAbbrevValue=""
        cat alarm/"$symbol".txt
        cat template/indexPart1b.html

        echo "'" "$symbolName" "',"
        cat template/indexPart2.html
    
        # Writing quotes
        echo "$commaPriceList"
        cat template/indexPart3.html

        # shellcheck disable=SC2154
        WriteTransactionFile "$lastDateInDataFile" "$symbol" "buy"
        cat buy/"$symbol".txt
        cat template/indexPart3a.html

        WriteTransactionFile "$lastDateInDataFile" "$symbol" "sell"
        cat sell/"$symbol".txt
        cat template/indexPart3b.html

        echo "'" Average $averageInDays18 "',"
        cat template/indexPart4.html
        echo "$averagePriceList18"
        cat template/indexPart5.html

        echo "'" Average $averageInDays38 "'," 
        cat template/indexPart6.html 
        echo "$averagePriceList38" 
        cat template/indexPart7.html  

        echo "'" Average $averageInDays95 "',"
        cat template/indexPart8.html
        echo "$averagePriceList95"

        # Draw 5% lines
        if [ "$markerOwnStock" = '*' ]; then
            # Get buying rate
            buyingRate=$(grep -F "$symbol" "$OWN_SYMBOLS_FILE" | cut -f2 -d ' ')
        else
            buyingRate=$last
        fi
        # Draw buying/last rate
        cat template/indexPart8a.html

        agregateBuyingrate=$(seq -s "XX," 88 | tr -d '[:digit:]')
        echo -n "$agregateBuyingrate" | sed "s/XX/${buyingRate}/g"

        # Draw 5% over buying/last quote
        cat template/indexPart8b.html
        percentOverBuyingLastRate=$(echo "$buyingRate 1.05" | awk '{print $1 * $2}')
        agregatePercentOverBuyingLastRate=$(seq -s "XX," 88 | tr -d '[:digit:]')
        echo -n "$agregatePercentOverBuyingLastRate" | sed "s/XX/${percentOverBuyingLastRate}/g"

        cat template/indexPart9.html
        cat alarm/"$symbol".txt
        cat template/indexPart9b.html

        echo "$stochasticQuoteList"
        cat template/indexPart10.html
        cat alarm/"$symbol".txt
        cat template/indexPart10b.html        

        echo "$RSIQuoteList"
        cat template/indexPart11.html
        cat alarm/"$symbol".txt
        cat template/indexPart11b.html        

        echo "$MACDList"
        cat template/indexPart12.html

        COMDIRECT_URL_10D="$COMDIRECT_URL_STOCKS_PREFIX_10D"
        COMDIRECT_URL_6M="$COMDIRECT_URL_STOCKS_PREFIX_6M"
        COMDIRECT_URL_5Y="$COMDIRECT_URL_STOCKS_PREFIX_5Y"
        if [ "$asset_type" = 'INDEX' ]; then
            COMDIRECT_URL_10D="$COMDIRECT_URL_INDEX_PREFIX_10D"
            COMDIRECT_URL_6M="$COMDIRECT_URL_INDEX_PREFIX_6M"
            COMDIRECT_URL_5Y="$COMDIRECT_URL_INDEX_PREFIX_5Y"
        fi
        echo "<a $styleComdirectLink onmouseover=\"javascript:showChart('10D')\" onmouseout='javascript:hideChart()' href=\"$COMDIRECT_URL_10D""$ID_NOTATION"\" " target=\"_blank\">$markerOwnStock$symbol $symbolName</a>"
        echo "<a $styleComdirectLink onmouseover=\"javascript:showChart('6M')\" onmouseout='javascript:hideChart() 'href=\"$COMDIRECT_URL_6M""$ID_NOTATION"\" " target=\"_blank\">&nbsp;6M&nbsp;</a>"
        echo "<a $styleComdirectLink onmouseover=\"javascript:showChart('5Y')\" onmouseout='javascript:hideChart()' href=\"$COMDIRECT_URL_5Y""$ID_NOTATION"\" " target=\"_blank\">&nbsp;5Y&nbsp;</a>"
        echo "&nbsp;&nbsp;<span style='font-size:50px; color:rgb(0, 0, 0)'><b>$last€</b></span>"
        echo "&nbsp;<span style='font-size:50px; color:$_linkColor'><b>""$percentLastDay""%</b></span><br>" 

        if [ "$asset_type" = 'STOCK' ] || [ "$asset_type" = 'INDEX' ]; then            
            # KGVe
            kgve=$(echo "$lineFromTickerFile" | cut -f 6)          
            echo "<span style='font-size:50px'>KGV&nbsp;$kgve&nbsp;&nbsp;&nbsp;</span>&nbsp;"
            # DIVe
            dive=$(echo "$lineFromTickerFile" | cut -f 7)
            echo "<span style='font-size:50px'>DIV&nbsp;$dive%&nbsp;&nbsp;&nbsp;</span>&nbsp;"

            # hover Firmenportrait Text
            echo "<style>
            .tooltip {
                display: inline-block;
                border-bottom: 2px dotted black; 
                font-size: 50px;
                line-height: 37px;
                vertical-align: baseline;
            }
            .tooltip .tooltiptext {
                visibility: hidden;
                background-color: black;
                color: #fff;
                //padding: 7px 10px;
                padding: 7px 10px 20px 10px;
                border-radius: 6px;
                position: absolute;
                z-index: 1;
                font-size: 50px;
                margin: 10px 0px 0px -410px;
                line-height: 100%;
            }
            .tooltip:hover .tooltiptext {
                visibility: visible;
            }
            </style>"

            # Branche und Firmenportrait Tooltip
            branche=$(echo "$lineFromTickerFile" | cut -f 5)
            firmenportrait=$(echo "$lineFromTickerFile" | cut -f 10)
            echo "<div class='tooltip'>$branche<br><div class='tooltiptext'>$firmenportrait</div></div></p>"

            # Market Cap Progressbar, only if number
            if [ "$marketCapFromFile" = '?' ]; then
                echo "<p class='p-result' id='lowMarketCapId'><b style='color:black; font-size:x-large; background: rgba(244,164,80,255);'>->LOW CAP&nbsp;$marketCapFromFile Mrd.€</b></p>"
                echo "" # Extra line, because of GOOD LUCK replacemant. Low Market Cap Symbol files need the same length!
            else
                marketCapScaled=$((marketCapFromFile * 5)) # Scale factor in progressbar
                # shellcheck disable=SC2086,SC2027
                echo "<style>#progress:after { content: ''; display: block; background: rgba(244,164,80,255); width: ""$marketCapScaled""px; height: 100%; border-radius: 9px; margin-top: -21px;}</style>"
                echo "<div id='progress' style='background: rgba(240,236,236,255); border-radius: 13px; height: 24px; width: 98%; padding: 3px; text-align: left'>&nbsp;Market Cap&nbsp;$marketCapFromFile Mrd.€</div><br>"
            fi
        fi

        echo "<br><p class='p-result'>"
        quoteDate=$(head -n1 "$DATA_DATE_FILE" | awk '{print $1}')
        echo "<b>$quoteDate</b>"
        echo "<b>&nbsp;&nbsp;$asset_type</b>"
        if [ "$asset_type" = 'STOCK' ]; then
            echo "<b>&nbsp;&nbsp;HV:$hauptversammlung</b>"
        fi
        echo "</p>"

        echo "<p class='p-result'>"
        echo "<span style='color:rgb(153, 102, 255)'>Avg18:<b>""$average18""€</b></span>"
        echo "&nbsp;<span style='color:rgb(205, 99, 132)'>Avg38:<b>""$average38""€</b></span>"
        echo "&nbsp;<span style='color:rgb(75, 192, 192)'>Avg95:<b>""$average95""€</b></span>"
        echo "&nbsp;<span style='color:rgb(255, 159, 64)'>Stoch14:<b>""$lastStochasticQuoteRounded" "</b></span>"
        echo "&nbsp;<span style='color:rgb(255, 205, 86)'>RSI14:<b>""$lastRSIQuoteRounded" "</b></span>"
        echo "&nbsp;<span style='color:rgb(54, 162, 235)'>MACD:<b>""$lastMACDValue" "</b></span>"
        echo "</p>"
        echo "<p class='p-result'>"
        echo "<span style='color:rgb(153, 102, 255)'>Tendency18:<b>""$tendency18""</b></span>"
        echo "&nbsp;<span style='color:rgb(205, 99, 132)'>Tendency38:<b>""$tendency38""</b></span>"
        echo "</p>"

        # Strategies output
        # Sell/Buy
        echo "<p class='p-result' style='color:rgb(205, 99, 132)'><b>" "$resultStrategieByTendency" "</b></p>"
        
        # Buy
        echo "<p class='p-result' style='color:rgb(0, 0, 0)'><b>" "$resultStrategieUnderratedNewLow" "</b></p>"
        echo "<p class='p-result' style='color:rgb(245, 111, 66)'><b>" "$resultStrategieUnderratedDivergenceRSI" "</b></p>"
        echo "<p class='p-result' style='color:rgb(54, 162, 235)'><b>" "$resultStrategieUnderratedLowHorizontalMACD" "</b></p>"
        echo "<p class='p-result' style='color:rgb(205, 205, 0)'><b>" "$resultStrategieUnderratedByPercentAndStochastic" "</b></p>"
        echo "<p class='p-result' style='color:rgb(255, 159, 64)'><b>" "$resultStrategieUnderratedXLowStochastic" "</b></p>"
        echo "<p class='p-result' style='color:rgb(255, 205, 86)'><b>" "$resultStrategieUnderratedXLowRSI" "</b></p>"
        echo "<p class='p-result' style='color:rgb(139, 126, 102)'><b>" "$resultStrategieUnderratedLowStochasticLowRSILowMACD" "</b></p>"
        
        # Sell
        echo "<p class='p-result' style='color:rgb(245, 111, 166)'><b>" "$resultStrategieOverratedStochasticWhenOwn" "</b></p>"
        echo "<p class='p-result' style='color:rgb(245, 111, 66)'><b>" "$resultStrategieOverratedDivergenceRSI" "</b></p>"
        echo "<p class='p-result' style='color:rgb(54, 162, 235)'><b>" "$resultStrategieOverratedHighHorizontalMACD" "</b></p>"
        echo "<p class='p-result' style='color:rgb(205, 205, 0)'><b>" "$resultStrategieOverratedByPercentAndStochastic" "</b></p>"
        echo "<p class='p-result' style='color:rgb(255, 159, 64)'><b>" "$resultStrategieOverratedXHighStochastic" "</b></p>"
        echo "<p class='p-result' style='color:rgb(255, 205, 86)'><b>" "$resultStrategieOverratedXHighRSI" "</b></p>"
        echo "<p class='p-result' style='color:rgb(139, 126, 102)'><b>" "$resultStrategieOverratedHighStochasticHighRSIHighMACD" "</b></p>"

        echo "<br>$GOOD_LUCK"

        cat template/indexPart13.html
    } >> "$indexSymbolFile"

    # Minify <Symbol>.html file
    sed -i "s/^[ \t]*//g" "$indexSymbolFile"
    sed -i ":a;N;$!ba;s/\n//g" "$indexSymbolFile" # Remove \n. Attention: will remove \n in Javascript!

    WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$symbol" "$symbolName" "$BLACK" "$markerOwnStock" "" "$lowMarketCapLinkBackgroundColor"

    if [ "$markerOwnStock" = '*' ] && [ "$buyingRate" ]; then
        counterOwnStocks=$((counterOwnStocks+1)) # For Spinner

        stocksPieces=$(grep -F "$symbol" "$OWN_SYMBOLS_FILE" | cut -f4 -d ' ')
        stocksBuyingValue=$(echo "$stocksPieces $buyingRate" | awk '{print $1 * $2}')
        stocksBuyingValue=$(printf "%.0f" "$stocksBuyingValue")
        stocksCurrentValue=$(echo "$stocksPieces $last" | awk '{print $1 * $2}')
        stocksCurrentValue=$(printf "%.0f" "$stocksCurrentValue")
        stocksPerformance=$(echo "$stocksCurrentValue $stocksBuyingValue" | awk '{print (($1 / $2)-1)*100}')
        stocksPerformance=$(printf "%.1f" "$stocksPerformance")
        obfuscatedValuePcEuro="$stocksPieces"XX"$stocksBuyingValue"/"$stocksCurrentValue"YY
        obfuscatedValuePcEuro=$(echo "$obfuscatedValuePcEuro" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta')

        obfuscatedValueGain=$(echo "$stocksCurrentValue $stocksBuyingValue" | awk '{print $1 - $2}')
        obfuscatedValueGain="$stocksPerformance"ZZ"$obfuscatedValueGain"YY
        obfuscatedValueGain=$(echo "$obfuscatedValueGain" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta')
        isNegativ=${stocksPerformance:0:1}
        _linkColor="$GREEN"
        if [ "$isNegativ" = '-' ]; then
            _linkColor="$RED"
        fi

        {
            # RealTimeQuote
            # shellcheck disable=SC1078,SC1087,SC1079
            echo "<script>
                linkMap.set('$symbol', 'https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/""$symbol"".html'); // Open in Tab
                counterOwnStocks=$counterOwnStocks; // For Spinner
                document.addEventListener('DOMContentLoaded', onContentLoaded('$symbol', '$ID_NOTATION', '$asset_type'));
            </script>"
                        
            echo "<span id='intervalSectionRealTimeQuote$symbol' style='font-size:xx-large; display: none'>---</span>&nbsp;
                  <span id='intervalSectionPercentage$symbol' style='font-size:xx-large; display: none'></span>
                  <span id='intervalSectionGain$symbol' style='font-size:xx-large; display: none'></span>
                  <span id='neverShowRegularMarketTime$symbol' style='display: none'></span>
                  <span id='intervalSectionPortfolioValues$symbol' style='font-size:large; display: none'></span>
                  <span id='intervalSectionPortfolioGain$symbol' style='font-size:large; display: none'></span>
                  <span id='intervalSectionButtonDetailsBR$symbol'><br></span>"

            # ObfuscatedValue neverShowDiv (Yesterday)
            echo "<div id='neverShowDiv$symbol' style='display:none'>
                   <span id='obfuscatedValuePcEuro$symbol' style='display:none'>$obfuscatedValuePcEuro</span>&nbsp;
                   <span id='obfuscatedValueGain$symbol' style='display:none;color:$_linkColor'>$obfuscatedValueGain</span>
                   <span id='obfuscatedValueCloseBraces$symbol' style='display:none'>)yadretseY(</span> <!-- (Yesterday) -->
                 </div>"

            # Interval Beep
            echo "<span id='intervalSectionBeep$symbol' style='font-size:large; display: none'><br>"
            echo "Delay: <span id='intervalSectionRegularMarketTimeOffset$symbol' style='font-size:large; display: none'></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name='intervalField$symbol' id='intervalField$symbol' type='text' style='height: 45px;' maxlength='3' size='3' value='10'/>&nbsp;<button type='button' id='intervalButton$symbol' style='font-size:large; height: 50px; width: 97px' onClick=\"javascript:setBeepInterval('$symbol')\">Minutes</button><span id='intervalText$symbol'></span>"
            echo "</span>"

            # Image Chart
            echo "<br><img id='intervalSectionImage$symbol' alt='' src='#' style='display: none; width:68%'><br>
                  <button id=\"intervalSectionButtonDetails1D$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '1D')\">1D</button>
                  <button id=\"intervalSectionButtonDetails5D$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '5D')\">5D</button>
                  <button id=\"intervalSectionButtonDetails10D$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '10D')\">10D</button>
                  <button id=\"intervalSectionButtonDetails3M$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '3M')\">3M</button>
                  <button id=\"intervalSectionButtonDetails6M$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '6M')\">6M</button>
                  <button id=\"intervalSectionButtonDetails1Y$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '1Y')\">1Y</button>
                  <button id=\"intervalSectionButtonDetails5Y$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', '5Y')\">5Y</button>
                  <button id=\"intervalSectionButtonDetailsSE$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:updateImage('$symbol', '$ID_NOTATION', 'SE')\">Max</button>
                  <p id='intervalSectionButtonDetailsP$symbol' style='display: none'>
                    <button id=\"intervalSectionButtonSell$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:curlSell('$symbol', '$stocksPieces', document.getElementById('intervalSectionInputPriceBuy$symbol').value)\">Sell</button>
                    <button id=\"intervalSectionButtonBuy$symbol\" style='font-size:large; height: 50px; width: 80px; display: none' type=\"button\" onClick=\"javascript:curlBuy(
                        '$symbol', document.getElementById('intervalSectionInputPriceBuy$symbol').value, document.getElementById('intervalSectionInputPiecesBuy$symbol').value)\">ReBuy</button>
                    Pieces&nbsp;<input name='intervalSectionInputPiecesBuy$symbol' id='intervalSectionInputPiecesBuy$symbol' style='display: none; height: 45px;' type='text' maxlength='7' value='' size='5'/>
                    Price&nbsp;<input name='intervalSectionInputPriceBuy$symbol' id='intervalSectionInputPriceBuy$symbol' style='display: none; height: 45px;' type='text' maxlength='7' value='' size='5'/>
                  </p>
                  <hr id='intervalSectionButtonDetailsHR$symbol' style='display: none'>"

            # Sorting End symbolsListId
            echo "</div>"

        } >> $OUT_RESULT_FILE

        # Collect Values for Overall Yesterday
        obfuscatedValueBuyingOverall=$(echo "$obfuscatedValueBuyingOverall $stocksBuyingValue" | awk '{print $1 + $2}')
        obfuscatedValueSellingOverall=$(echo "$obfuscatedValueSellingOverall $stocksCurrentValue" | awk '{print $1 + $2}')
    else
        echo "</div>" >> $OUT_RESULT_FILE
    fi

    # Write history file
    HISTORY_FILE=history/"$symbol".txt
    rm -rf "$HISTORY_FILE"
    PRE_FIX="100,100,100,100,100,100,100,100,100,100,100,100,100,"

    commaPriceList=$(echo "$commaPriceList" | sed -e :a -e 'N;s/\n//g;ta')
    echo "# Quote oldest,..,newest" >> "$HISTORY_FILE"
    echo "$PRE_FIX$commaPriceList" >> "$HISTORY_FILE"
    
    # shellcheck disable=SC2001
    stochasticQuoteList=$(echo "$stochasticQuoteList" | sed 's/ //g')
    echo "# Stoch oldest,..,newest" >> "$HISTORY_FILE"
    echo "$PRE_FIX$stochasticQuoteList" >> "$HISTORY_FILE"

    # shellcheck disable=SC2001
    RSIQuoteList=$(echo "$RSIQuoteList" | sed 's/ //g')
    echo "# RSI oldest,..,newest" >> "$HISTORY_FILE"
    echo "$PRE_FIX$RSIQuoteList" >> "$HISTORY_FILE"

    # shellcheck disable=SC2001
    MACDList=$(echo "$MACDList" | sed 's/ //g')
    echo "# MACD oldest,..,newest" >> "$HISTORY_FILE"
    echo "$PRE_FIX$MACDList" >> "$HISTORY_FILE"
done

# Overall
if [ "$obfuscatedValueBuyingOverall" ]; then
    obfuscatedValueBuyingSellingOverall="$obfuscatedValueBuyingOverall"/"$obfuscatedValueSellingOverall"YY
    obfuscatedValueBuyingSellingOverall=$(echo "$obfuscatedValueBuyingSellingOverall" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta')

    stocksPerformanceOverall=$(echo "$obfuscatedValueSellingOverall $obfuscatedValueBuyingOverall" | awk '{print (($1 / $2)-1)*100}')
    stocksPerformanceOverall=$(printf "%.1f" "$stocksPerformanceOverall")
    obfuscatedValueGainOverall=$(echo "$obfuscatedValueSellingOverall $obfuscatedValueBuyingOverall" | awk '{print $1 - $2}')
    obfuscatedValueGainOverall="$stocksPerformanceOverall"ZZ # "$obfuscatedValueGainOverall"YY
    obfuscatedValueGainOverall=$(echo "$obfuscatedValueGainOverall" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta')
    isNegativ=${stocksPerformanceOverall:0:1}
    _linkColor="$GREEN"
    if [ "$isNegativ" = '-' ]; then
        _linkColor="$RED"
    fi
fi

{
    # Overall
    echo "<br><br><div id='portfolioValueDaxFooterId'>" # START portfolioValueDaxFooterId
    echo "<hr id='intervalSectionHROverallRealtimeBegin' style='display: none'>"
    echo "<span id='intervalSectionHeadlineOverallPortfolio' style='display:none'># Portfolio value purchase</span><br>"
    echo "<span id='obfuscatedValueBuyingOverall' style='font-size:large; display:none'>$obfuscatedValueBuyingSellingOverall</span>"
    echo "<br><br><span id='intervalSectionHeadlineOverallRealtime' style='display:none'># Realtime difference to purchase</span><br>"
    echo "<span id='obfuscatedValueBuyingOverallRealtime' style='font-size:xx-large; display:none'>---</span>"
    echo "<hr id='intervalSectionHROverallRealtime' style='display: none'>"

    # DAX
    echo "<span id='intervalSectionHeadlineDAX' style='display:none'>DAX<br></span>"
    echo "<img id='intervalSectionImageDAX' alt='' src='#' style='display: none; width:68%'><br>
        <button id='intervalSectionButton1DDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '1D')\">1D</button>
        <button id='intervalSectionButton5DDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '5D')\">5D</button>
        <button id='intervalSectionButton10DDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '10D')\">10D</button>
        <button id='intervalSectionButton3MDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '3M')\">3M</button>
        <button id='intervalSectionButton6MDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '6M')\">6M</button>
        <button id='intervalSectionButton1YDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '1Y')\">1Y</button>
        <button id='intervalSectionButton5YDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', '5Y')\">5Y</button>
        <button id='intervalSectionButtonSEDAX' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:updateImage('DAX', '35803356', 'SE')\">Max</button>
        <hr id='intervalSectionHRDAX' style='display: none'>"

    symbolsParam="$symbolsParam *DAX"

    WriteOverallChartsButtons "$symbolsParam" "1D"
    WriteOverallChartsButtons "$symbolsParam" "5D"
    WriteOverallChartsButtons "$symbolsParam" "10D"
    WriteOverallChartsButtons "$symbolsParam" "3M"
    WriteOverallChartsButtons "$symbolsParam" "6M"
    WriteOverallChartsButtons "$symbolsParam" "1Y"
    WriteOverallChartsButtons "$symbolsParam" "5Y"
    WriteOverallChartsButtons "$symbolsParam" "SE"

    # Generell Buy Elements
    echo "<br><br>
          <span id='intervalSectionButtonBuyGenerellParagraph' style='display: none'>
            Buy new Symbols (Enter Values from single order):
            <br>
            <button id='intervalSectionButtonBuyGenerellButton' style='font-size:large; height: 50px; width: 80px; display: none' type='button' onClick=\"javascript:curlBuy(
                document.getElementById('intervalSectionInputSymbolBuyGenerell').value, document.getElementById('intervalSectionInputPriceBuyGenerell').value, document.getElementById('intervalSectionInputPiecesBuyGenerell').value)\">Buy</button>
            Symbol&nbsp;<input name='intervalSectionInputSymbolBuyGenerell' id='intervalSectionInputSymbolBuyGenerell' style='display: none; height: 45px;' type='text' maxlength='7' value='' size='5'/>
            Pieces&nbsp;<input name='intervalSectionInputPiecesBuyGenerell' id='intervalSectionInputPiecesBuyGenerell' style='display: none; height: 45px;' type='text' maxlength='7' value='' size='5'/>
            Price&nbsp;<input name='intervalSectionInputPriceBuyGenerell' id='intervalSectionInputPriceBuyGenerell' style='display: none; height: 45px;' type='text' maxlength='7' value='' size='5'/>
          </span>"
        #</p>"

    # Workflow        
    echo "<br><br># Workflow<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=\"_blank\">Github Action</a><br>"
    # Result        
    echo "<br># Result<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result_schedule.html\" target=\"_blank\">Result Schedule SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result.html\" target=\"_blank\">Result&nbsp;SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate.html\" target=\"_blank\">Simulation</a><br>"
    # Informer        
    echo "<br># Informer<br><a href=\"https://nutzer.comdirect.de/inf/musterdepot/pmd/meineuebersicht.html?name=Max\" target=\"_blank\">Comdirect Informer</a><br>"
    echo "</div>" # END portfolioValueDaxFooterId
    echo "$HTML_RESULT_FILE_END" 
} >> "$OUT_RESULT_FILE"

# Minify _result.html file
sed -i "s/^[ \t]*//g" "$OUT_RESULT_FILE" # Remove Tabs from beginning of line
sed -i ":a;N;$!ba;s/\n//g" "$OUT_RESULT_FILE" # Remove \n. Attention: will remove \n in Javascript!

# Delete decrypted, readable portfolio file
rm -rf "$OWN_SYMBOLS_FILE"

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
