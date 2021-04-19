#!/bin/sh

# This script checks given stock quotes and their averages of the last 95, 38, 18 days.
# Stochastic, RSI and MACD are calculated as well
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query over REST API.
# 4. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 5. Parameter: RSI: Quote for RSI indicator (only 30 and less allowed!)
# Call example: ./analyse.sh 'BEI *ALV' 1 online 9 30
# Call example: ./analyse.sh 'BEI' 2 offline 9 30
# Call example: ./analyse.sh '*BEI' 1 offline 9 30
# Precondition:
# Set MARKET_STACK_ACCESS_KEY1, MARKET_STACK_ACCESS_KEY2, MARKET_STACK_ACCESS_KEY3, MARKET_STACK_ACCESS_KEY4 and MARKET_STACK_ACCESS_KEY5 as ENV Variable (Online)
# Set GPG_PASSPHRASE as ENV Variable
# shellcheck disable=SC1091 

# Import
. ./script/constants.sh
. ./script/functions.sh
. ./script/averages.sh
. ./script/strategies.sh

# Switches for calculating charts and underlying strategies. Default is 'true'
CalculateStochastic=true
CalculateRSI=true
CalculateMACD=true

# Switches to turn on/off Strategies. Default is 'true'
ApplyStrategieByTendency=false
ApplyStrategieHorizontalMACD=false

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
stochasticPercentageParam=$4
RSIQuoteParam=$5

# Prepare
rm -rf /dev/shm/tmp.*
mkdir -p out
mkdir -p temp
cp template/favicon.ico out
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
OWN_SYMBOLS_FILE=config/own_symbols.txt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null
#reportedSymbolFileList=""
alarmAbbrevValue=""
TICKER_NAME_ID_FILE=config/ticker_name_id.txt
HTML_RESULT_FILE_HEADER="<!DOCTYPE html><html lang=\"en\"><head><link rel=\"shortcut icon\" type=\"image/ico\" href=\"favicon.ico\" /><title>Result SA</title><style>.green {color:green;}.red {color:red;}.black {color:black;}.colored {color:blue;}#body {font-size: 14px;}@media screen and (min-width: 500px){}</style></head><body><div><p>"
echo "$HTML_RESULT_FILE_HEADER" > $OUT_RESULT_FILE
HTML_RESULT_FILE_END="</p><p>Good Luck! <a href="https://www.paypal.com/donate/?hosted_button_id=G2CERK22Q4QP8" target="_blank">Donate?</a></p></div></body></html>"
COMDIRECT_URL_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?timeSpan=6M&chartType=MOUNTAIN&useFixAverage=false&freeAverage0=95&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1&ID_NOTATION="
START_TIME_MEASUREMENT=$(date +%s);

# Check for multiple identical symbols in cmd. Do not ignore '*'' 
if echo "$symbolsParam" | tr -d '*' | tr '[:lower:]' '[:upper:]' | tr " " "\n" | sort | uniq -c | grep -v '^ *1 '; then
    echo "WARNING: Multiple symbols in parameter list!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" "$percentageParam" "$queryParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE

if [ ! "$CalculateStochastic" = true ] || [ ! "$CalculateRSI" = true ] || [ ! "$CalculateMACD" = true ]; then
    echo "WARNING: CalculateStochastic or CalculateRSI or CalculateMACD NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

if { [ -z "$GPG_PASSPHRASE" ]; } then
    echo "Error GPG_PASSPHRASE NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 6
fi

if { [ "$queryParam" = 'online' ]; } &&
   { [ -z "$MARKET_STACK_ACCESS_KEY1" ] || [ -z "$MARKET_STACK_ACCESS_KEY2" ] || [ -z "$MARKET_STACK_ACCESS_KEY3" ] || [ -z "$MARKET_STACK_ACCESS_KEY4" ] || [ -z "$MARKET_STACK_ACCESS_KEY5" ]; } then
    echo "Error 'online' query: MARKET_STACK_ACCESS_KEY1...5 NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 7
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

# RSI percentage
RSIQuoteLower=$RSIQuoteParam
RSIQuoteUpper=$((100-RSIQuoteParam))

# Stochastics percentage
stochasticPercentageLower=$stochasticPercentageParam
stochasticPercentageUpper=$((100-stochasticPercentageParam))

echo "# Analyse Parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage:$percentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Query:$queryParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic:$stochasticPercentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI:$RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "<br><br># Workflow Result<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=\"_blank\">Github Action</a><br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result_schedule.html\" target=\"_blank\">Github Result Schedule SA</a><br><br># Links (Comdirect, PC, Github)<br>" >> $OUT_RESULT_FILE

# Analyse stock data for each symbol
for symbol in $symbolsParam
do
    # Stocks with prefix '*' are marked as own stocks
    markerOwnStock=""
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        markerOwnStock="*"
        symbol=$(echo "$symbol" | cut -b 2-6)
    fi

    # Curl symbol name with delay of 14sec because of REST API restrictions
    CurlSymbolName "$symbol" $TICKER_NAME_ID_FILE 14

    # Get stock data
    echo ""
    echo "# Get $symbol $symbolName"
    DATA_FILE="$(mktemp -p /dev/shm/)"
    DATA_DATE_FILE=data/${symbol}.txt
    if [ "$queryParam" = 'online' ]; then
        tag=$(date +"%s") # Second -> date +"%s" ; Day -> date +"%d"
        evenodd=$((tag % 5))
        if [ "$evenodd" -eq 0 ]; then
            MARKET_STACK_ACCESS_KEY=${MARKET_STACK_ACCESS_KEY1}
        fi
        if [ "$evenodd" -eq 1 ]; then
            MARKET_STACK_ACCESS_KEY=${MARKET_STACK_ACCESS_KEY2}
        fi
        if [ "$evenodd" -eq 2 ]; then
            MARKET_STACK_ACCESS_KEY=${MARKET_STACK_ACCESS_KEY3}
        fi
        if [ "$evenodd" -eq 3 ]; then
            MARKET_STACK_ACCESS_KEY=${MARKET_STACK_ACCESS_KEY4}
        fi
        if [ "$evenodd" -eq 4 ]; then
            MARKET_STACK_ACCESS_KEY=${MARKET_STACK_ACCESS_KEY5}
        fi
        DATA_DATE_FILE_TEMP="$(mktemp -p /dev/shm/)"
        cp "$DATA_DATE_FILE" "$DATA_DATE_FILE_TEMP"
        curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}.XETRA" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}' > "$DATA_DATE_FILE"
        fileSize=$(stat -c %s "$DATA_DATE_FILE")
        if [ "${fileSize}" -eq "0" ]; then
            echo "!!! $symbol NOT found online" | tee -a $OUT_RESULT_FILE
            echo "<br>" >> $OUT_RESULT_FILE
            mv "$DATA_DATE_FILE_TEMP" "$DATA_DATE_FILE"
        fi
    fi

    symbolName=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE" | cut -f 2)

    CreateCmdAnalyseHyperlink

    ProgressBar 1 8

    #Check if 100 last quotes are availible, otherwise fill up to 100 
    numOfQuotes=$(grep "" -c "$DATA_DATE_FILE")
    if [ "$numOfQuotes" -lt 100 ]; then
        echo "!!! LESS then 100 quotes for $symbol" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
        lastQuoteInFile=$(tail -1 "$DATA_DATE_FILE" | cut -f 2)
        numOfQuotesToAdd=$((100 - $numOfQuotes))
        indexWhile=0
        while [ "$indexWhile" -lt "$numOfQuotesToAdd" ]; do
            echo "9999-99-99	"$lastQuoteInFile"" >> "$DATA_DATE_FILE"
            indexWhile=$((indexWhile + 1))
        done
    fi

    awk '{print $2}' "$DATA_DATE_FILE" > "$DATA_FILE"
    lastRaw=$(head -n1 "$DATA_FILE")
    last=$(printf "%.2f" "$lastRaw")
    # Check for unknown or not fetched symbol in cmd or on marketstack.com
    if [ "${#lastRaw}" -eq 0 ]; then
        echo "!!! $symbol NOT found in data/$symbol.txt" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
        # continue with next symbol in the list
        continue
    fi

    # Calculate MACD 12, 26 values
    if [ "$CalculateMACD" = true ]; then
        # EMAverage 12
        averageInDays12=12
        averagePriceList=""
        EMAverageOfDays $averageInDays12 "$DATA_FILE"
        averagePriceList12=$averagePriceList
        # EMAverage 26
        averageInDays26=26
        averagePriceList=""
        EMAverageOfDays $averageInDays26 "$DATA_FILE"
        averagePriceList26=$averagePriceList
        # MACD
        lastMACDValue=""
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
    LessThenWithFactor "$percentageLesserFactor" "$last" "$average38";lastUnderAgv38=$?

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
    RSIInDays14=14
    lastRSIQuoteRounded=""
    RSIQuoteList=""
    if [ "$CalculateRSI" = true ]; then
        RSIOfDays $RSIInDays14 "$DATA_FILE"
    fi

    ProgressBar 4 8

    # Calculate Stochastic 14 values
    stochasticInDays14=14
    lastStochasticQuoteRounded=""
    stochasticQuoteList=""
    if [ "$CalculateStochastic" = true ]; then
        StochasticOfDays $stochasticInDays14 "$DATA_FILE"
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

    tendency=""
    DetermineTendency "$averagePriceList95"

    ProgressBar 8 8
    
    #
    # Apply strategies
    #

    # Valid data is more then 200kb. Oherwise data might be damaged or unsufficiant
    fileSize=$(stat -c %s "$DATA_FILE")
    if [ "$fileSize" -gt 200 ]; then

        # Strategie: Quote by Tendency
        if [ "$ApplyStrategieByTendency" = true ]; then
            resultStrategieByTendency=""
            StrategieByTendency "$last" "$tendency" "$percentageLesserFactor" "$average95" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
        fi

        # Buy Strategie: Low horizontal MACD
        if [ "$ApplyStrategieHorizontalMACD" = true ]; then
            resultStrategieUnderratedLowHorizontalMACD=""
            StrategieUnderratedLowHorizontalMACD "$MACDList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
        fi

        # Buy Strategie: Low Percentage & Stochastic
        resultStrategieUnderratedByPercentAndStochastic=""
        StrategieUnderratedByPercentAndStochastic "$lastStochasticQuoteRounded" "$stochasticPercentageLower" "$lastUnderAgv18" "$lastUnderAgv38" "$lastUnderAgv95" "$agv18UnderAgv38" "$agv38UnderAgv95" "$agv18UnderAgv95" "$last" "$percentageGreaterFactor" "$average18" "$average38" "$average95" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
    
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

        # Sell Strategie: High Percentage & Stochastic
        resultStrategieOverratedByPercentAndStochastic=""
        StrategieOverratedByPercentAndStochastic "$lastStochasticQuoteRounded" "$stochasticPercentageUpper" "$lastOverAgv18" "$lastOverAgv38" "$lastOverAgv95" "$agv18OverAgv38" "$agv38OverAgv95" "$agv18OverAgv95" "$last" "$percentageLesserFactor" "$average18" "$average38" "$average95" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

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
        # shellcheck disable=SC3037
        echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
    fi

    #
    # Write Chart
    #
    indexSymbolFile=out/${symbol}.html
    rm -rf "$indexSymbolFile"
    {
        cat template/indexPart0.html
        echo "${markerOwnStock}${symbol}"
        cat template/indexPart1.html

        # Color result link in Chart
        styleComdirectLink="style=\"font-size:x-large; color:black\""
        # Red link only for stocks that are marked as own stocks
        if [ "${markerOwnStock}" = '*' ] &&
           {
            [ "$(echo "$resultStrategieByTendency" | cut -f 1 -d ':')" = "Sell" ] ||
            [ "${#resultStrategieOverratedHighHorizontalMACD}" -gt 1 ] || [ "${#resultStrategieOverratedByPercentAndStochastic}" -gt 1 ] ||
            [ "${#resultStrategieOverratedXHighStochastic}" -gt 1 ] || [ "${#resultStrategieOverratedXHighRSI}" -gt 1 ] ||
            [ "${#resultStrategieOverratedHighStochasticHighRSIHighMACD}" -gt 1 ]; } then
            styleComdirectLink="style=\"font-size:x-large; color:red\""
        fi

        if 
           [ "$(echo "$resultStrategieByTendency" | cut -f 1 -d ':')" = "Buy" ] ||
           [ "${#resultStrategieUnderratedLowHorizontalMACD}" -gt 1 ] || [ "${#resultStrategieUnderratedByPercentAndStochastic}" -gt 1 ] ||
           [ "${#resultStrategieUnderratedXLowStochastic}" -gt 1 ] || [ "${#resultStrategieUnderratedXLowRSI}" -gt 1 ] ||
           [ "${#resultStrategieUnderratedLowStochasticLowRSILowMACD}" -gt 1 ]; then
            styleComdirectLink="style=\"font-size:x-large; color:green\""
        fi

        ID_NOTATION=$(grep -P "${symbol}\t" $TICKER_NAME_ID_FILE | cut -f 3)
        echo "<p><a $styleComdirectLink href="\""$COMDIRECT_URL_PREFIX""$ID_NOTATION"\" " target=\"_blank\">$markerOwnStock$symbol $symbolName</a><br>"
        echo "Percentage:<b>$percentageParam</b> "
        echo "Query:<b>$queryParam</b> "
        echo "Stochastic14:<b>$stochasticPercentageParam</b> "
        echo "RSI14:<b>$RSIQuoteParam</b><br>"

        # Check, if quote day is from last trading day, including weekend
        yesterday=$(date --date="-1 day" +"%Y-%m-%d")
        dayOfWeek=$(date +%u)
        if [ "$dayOfWeek" -eq 7 ]; then # 7 SUN
            yesterday=$(date --date="-2 day" +"%Y-%m-%d")
        fi
        if [ "$dayOfWeek" -eq 1 ]; then # 1 MON
            yesterday=$(date --date="-3 day" +"%Y-%m-%d")
        fi
        quoteDate=$(head -n1 "$DATA_DATE_FILE" | awk '{print $1}')
        if [ "$quoteDate" = "$yesterday" ]; then
            echo "Date:<b>$quoteDate</b>" # OK, quote from last trading day
        else
            echo "<br><b style=\"color:orange; font-size:large;\">->OLD DATA:$markerOwnStock$symbol</b><br>" >> $OUT_RESULT_FILE
            echo "Date:<b style=\"color:orange; font-size:xx-large;\">$quoteDate</b>"
        fi
        echo "&nbsp;<span style=\"color:rgb(0, 0, 0);\">Price:<b>""$last""€</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(153, 102, 255);\">Avg18:<b>""$average18""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 99, 132);\">Avg38:<b>""$average38""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Avg95:<b>""$average95""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Tendency:<b>""$tendency""</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 159, 64);\">Stoch14:<b>""$lastStochasticQuoteRounded" "</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 205, 86);\">RSI14:<b>""$lastRSIQuoteRounded" "</b></span>"
        echo "&nbsp;<span style=\"color:rgb(54, 162, 235);\">MACD:<b>""$lastMACDValue" "</b></span></p>"

        # Strategies output

        # Sell/Buy
        echo "<p style=\"color:rgb(75, 192, 192);\"><b>" "$resultStrategieByTendency" "</b></p>"
        
        # Buy
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieUnderratedLowHorizontalMACD" "</b></p>"
        echo "<p style=\"color:rgb(205, 205, 0);\"><b>" "$resultStrategieUnderratedByPercentAndStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieUnderratedXLowStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 205, 86);\"><b>" "$resultStrategieUnderratedXLowRSI" "</b></p>"
        echo "<p style=\"color:rgb(139, 126, 102);\"><b>" "$resultStrategieUnderratedLowStochasticLowRSILowMACD" "</b></p>"
        
        # Sell
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieOverratedHighHorizontalMACD" "</b></p>"
        echo "<p style=\"color:rgb(205, 205, 0);\"><b>" "$resultStrategieOverratedByPercentAndStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieOverratedXHighStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 205, 86);\"><b>" "$resultStrategieOverratedXHighRSI" "</b></p>"
        echo "<p style=\"color:rgb(139, 126, 102);\"><b>" "$resultStrategieOverratedHighStochasticHighRSIHighMACD" "</b></p>"
        
        cat template/indexPart1a.html

        WriteAlarmAbbrevXAxisFile "$alarmAbbrevValue" "$symbol" "$DATA_DATE_FILE" "alarm" "$markerOwnStock"
        alarmAbbrevValue=""
        cat alarm/"${symbol}".txt
        rm alarm/"${symbol}".txt
        cat template/indexPart1b.html

        echo "'" "${symbolName}" "',"
        cat template/indexPart2.html
    
        # Writing quotes
        DATA_FILE_87="$(mktemp -p /dev/shm/)"
        head -n87 "$DATA_FILE" > "$DATA_FILE_87"
        commaPriceList=$(awk '{ print $1","; }' < "$DATA_FILE_87" | tac)

        echo "$commaPriceList"
        cat template/indexPart3.html

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

        # Draw Buying Rate
        if [ "${markerOwnStock}" = '*' ]; then
            cat template/indexPart8a.html
            buyingRate=$(grep "${symbol}" $OWN_SYMBOLS_FILE  | cut -f2 -d ' ')
            i=1
            while [ "$i" -le 87 ]; do
                echo -n "$buyingRate,"
                i=$((i + 1))
            done

            # Draw 5 % over Buying Rate
            cat template/indexPart8b.html
            percentOverBuyingRate=$(echo "$buyingRate 1.05" | awk '{print $1 * $2}')
            i=1
            while [ "$i" -le 87 ]; do
                echo -n "$percentOverBuyingRate,"
                i=$((i + 1))
            done
        fi

        cat template/indexPart9.html

        echo "$stochasticQuoteList"
        cat template/indexPart10.html

        echo "$RSIQuoteList"
        cat template/indexPart11.html

        echo "$MACDList"
        cat template/indexPart12.html

        echo "<p><a $styleComdirectLink href="\""$COMDIRECT_URL_PREFIX""$ID_NOTATION"\" " target=\"_blank\">$markerOwnStock$symbol $symbolName</a><br>"
        echo "Good Luck! <a href="https://www.paypal.com/donate/?hosted_button_id=G2CERK22Q4QP8" target="_blank">Donate?</a><p>"

        cat template/indexPart13.html
    } >> "$indexSymbolFile"

    # Minify Symbol.html file
    sed -i "s/^[ \t]*//g" "$indexSymbolFile"
    sed -i ":a;N;$!ba;s/\n//g" "$indexSymbolFile"

    WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$symbol" "$symbolName" "$BLACK" "$markerOwnStock" ""

    if [ "${markerOwnStock}" = '*' ]; then
        stocksDate=$(grep "${symbol}" $OWN_SYMBOLS_FILE  | cut -f3 -d ' ')
        stocksPieces=$(grep "${symbol}" $OWN_SYMBOLS_FILE  | cut -f4 -d ' ')
        buyingValue=$(echo "$stocksPieces $buyingRate" | awk '{print $1 * $2}')
        stocksValue=$(echo "$stocksPieces $last" | awk '{print $1 * $2}')
        stocksPerformance=$(echo "$stocksValue $buyingValue" | awk '{print (($1 / $2)-1)*100}')
        stocksPerformance=$(printf "%.2f" "$stocksPerformance")
        #echo ""$stocksDate": "$stocksPieces"pc Buy:"$buyingValue"€ Curr:"$stocksValue"€ "$stocksPerformance"%" | tee -a $OUT_RESULT_FILE
        #echo "<br><br>" >> $OUT_RESULT_FILE
    fi

done

echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE

# Minify _result.html file
sed -i "s/^[ \t]*//g" "$OUT_RESULT_FILE"
sed -i ":a;N;$!ba;s/\n//g" "$OUT_RESULT_FILE"

# Delete readable file
rm -rf $OWN_SYMBOLS_FILE

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Tar 
# shell______check dis____________________able=SC2116,SC2086
#reportedSymbolFileList=$(echo $reportedSymbolFileList $OUT_RESULT_FILE)
