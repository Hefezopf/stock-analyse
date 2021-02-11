#!/bin/sh

# This script checks given stock quotes and their averages of the last 95, 38, 18 days.
# Stochastic, RSI and MACD are calculated as well
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'ADS *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query over REST API.
# 4. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 5. Parameter: RSI: Quote for RSI indicator (only 30 and less allowed!)
# Call example: ./analyse.sh 'ADS *ALV' 3 online 9 30
# Call example: ./analyse.sh 'ADS' 1 offline 9 30
# Call example: ./analyse.sh '*ADS' 1 offline 9 30
# Online Precondition:
# Set MARKET_STACK_ACCESS_KEY1, MARKET_STACK_ACCESS_KEY2 and MARKET_STACK_ACCESS_KEY3 and MARKET_STACK_ACCESS_KEY4 as ENV Variable
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
OUT_ZIP_FILE=_out.tar.gz
rm -rf out/$OUT_ZIP_FILE
touch out/$OUT_ZIP_FILE
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
reportedSymbolFileList=""
alarmAbbrevValue=""
TICKER_ID_NAMES_FILE=data/_ticker_id_names.txt
HTML_RESULT_FILE_HEADER="<html><head><link rel=\"shortcut icon\" type=\"image/ico\" href=\"_favicon.ico\" /><title>Result</title><style>.colored {color:blue;}#body {font-size: 14px;}@media screen and (min-width: 500px)</style></head><body><div><p>"
echo "$HTML_RESULT_FILE_HEADER" > $OUT_RESULT_FILE
HTML_RESULT_FILE_END="</p><p>Good Luck!</p></div></body></html>"
COMDIRECT_URL_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?timeSpan=6M&chartType=MOUNTAIN&useFixAverage=false&freeAverage0=95&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1&ID_NOTATION="
START_TIME_MEASUREMENT=$(date +%s);

# Check for multiple identical symbols in cmd. Do not ignore '*'' 
if echo "$symbolsParam" | tr -d '*' | tr '[:lower:]' '[:upper:]' | tr " " "\n" | sort | uniq -c | grep -v '^ *1 '; then
    echo "WARNING: Multiple symbols in parameter list!" | tee -a $OUT_RESULT_FILE #&& exit 4
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" "$percentageParam" "$queryParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE

if [ ! "$CalculateStochastic" = true ] || [ ! "$CalculateRSI" = true ] || [ ! "$CalculateMACD" = true ]; then
    echo "WARNING: CalculateStochastic or CalculateRSI or CalculateMACD NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

if { [ "$queryParam" = 'online' ]; } &&
   { [ -z "$MARKET_STACK_ACCESS_KEY1" ] || [ -z "$MARKET_STACK_ACCESS_KEY2" ] || [ -z "$MARKET_STACK_ACCESS_KEY3" ] || [ -z "$MARKET_STACK_ACCESS_KEY4" ]; } then
    echo "Error 'online' query: MARKET_STACK_ACCESS_KEY1 ... 4 NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 6
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
echo "<br><br># Workflow Result<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=_blank>Github Action</a><br><br># Comdirect Link<br>" >> $OUT_RESULT_FILE

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
    CurlSymbolName "$symbol" $TICKER_ID_NAMES_FILE 14

    # Get stock data
    echo ""
    echo "# Get $symbol $symbolName"
    DATA_FILE="$(mktemp -p /dev/shm/)"
    DATA_DATE_FILE=data/${symbol}.txt
    if [ "$queryParam" = 'online' ]; then
        tag=$(date +"%s") # Second -> date +"%s" ; Day -> date +"%d"
        evenodd=$((tag % 4))
        if [ "$evenodd" -eq 0 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY1}
        fi
        if [ "$evenodd" -eq 1 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY2}
        fi
        if [ "$evenodd" -eq 2 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY3}
        fi
        if [ "$evenodd" -eq 3 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY4}
        fi
        DATA_DATE_FILE_TEMP="$(mktemp -p /dev/shm/)"
        cp "$DATA_DATE_FILE" "$DATA_DATE_FILE_TEMP"
        curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${ACCESS_KEY}&exchange=XETRA&symbols=${symbol}.XETRA" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}' > "$DATA_DATE_FILE"
        fileSize=$(stat -c %s "$DATA_DATE_FILE")
        if [ "${fileSize}" -eq "0" ]; then
            echo "!!! $symbol NOT found online" | tee -a $OUT_RESULT_FILE
            echo "<br>" >> $OUT_RESULT_FILE
            mv "$DATA_DATE_FILE_TEMP" "$DATA_DATE_FILE"
        fi
    fi

    symbolName=$(grep -m1 -P "$symbol\t" "$TICKER_ID_NAMES_FILE" | cut -f 2)

    CreateCmdAnalyseHyperlink

    ProgressBar 1 8

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
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average18"; lastUnderAgv18=$?

    ProgressBar 2 8

    average38Raw=$(head -n38 "$DATA_FILE" | awk '{sum += $1;} END {print sum/38;}')
    average38=$(printf "%.2f" "$average38Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average38"; lastOverAgv38=$?
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average38";lastUnderAgv38=$?

    average95Raw=$(head -n95 "$DATA_FILE" | awk '{sum += $1;} END {print sum/95;}')
    average95=$(printf "%.2f" "$average95Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average95"; lastOverAgv95=$?
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average95"; lastUnderAgv95=$?

    # Percentage on averages
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average38"; agv18OverAgv38=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average18" "$average38"; agv18UnderAgv38=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average38" "$average95"; agv38OverAgv95=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average38" "$average95"; agv38UnderAgv95=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average95"; agv18OverAgv95=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average18" "$average95"; agv18UnderAgv95=$?
 
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
        resultStrategieByTendency=""
        StrategieByTendency "$last" "$tendency" "$percentageLesserFactor" "$average95" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # Buy Strategie: Low horizontal MACD
        resultStrategieUnderratedLowHorizontalMACD=""
        StrategieUnderratedLowHorizontalMACD "$MACDList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

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
        resultStrategieOverratedHighHorizontalMACD=""
        StrategieOverratedHighHorizontalMACD "$MACDList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

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
    cp js/_favicon.ico out
    {
        cat js/indexPart0.html
        echo "${markerOwnStock}${symbol}"
        cat js/indexPart1.html

        WriteAlarmAbbrevXAxisFile "$alarmAbbrevValue" "$symbol" "$DATA_DATE_FILE" "alarm"
        alarmAbbrevValue=""
        cat alarm/"${symbol}".txt
        cat js/indexPart1a.html

        echo "'" "${symbolName}" "',"
        cat js/indexPart2.html
    
        # Writing quotes
        DATA_FILE_90="$(mktemp -p /dev/shm/)"
        head -n90 "$DATA_FILE" > "$DATA_FILE_90"
        commaPriceList=$(awk '{ print $1","; }' < "$DATA_FILE_90" | tac)

        echo "$commaPriceList"
        cat js/indexPart3.html

        echo "'" Average $averageInDays18 "',"
        cat js/indexPart4.html
        echo "$averagePriceList18"
        cat js/indexPart5.html

        echo "'" Average $averageInDays38 "'," 
        cat js/indexPart6.html 
        echo "$averagePriceList38" 
        cat js/indexPart7.html  

        echo "'" Average $averageInDays95 "',"
        cat js/indexPart8.html
        echo "$averagePriceList95"
        cat js/indexPart9.html

        echo "$stochasticQuoteList"
        cat js/indexPart10.html

        echo "$RSIQuoteList"
        cat js/indexPart11.html

        echo "$MACDList"
        cat js/indexPart12.html

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

        ID_NOTATION=$(grep -P "${symbol}\t" $TICKER_ID_NAMES_FILE | cut -f 3)
        echo "<p><a $styleComdirectLink href=""$COMDIRECT_URL_PREFIX""$ID_NOTATION" " target=_blank>$markerOwnStock$symbol $symbolName</a><br>"
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
            echo "<b style=\"color:orange; font-size:large;\">->OLD DATA:$markerOwnStock$symbol</b><br>" >> $OUT_RESULT_FILE
            echo "Date:<b style=\"color:orange; font-size:xx-large;\">$quoteDate</b>"
        fi
        echo "&nbsp;<span style=\"color:rgb(0, 0, 0);\">Price:<b>""$last""€</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(153, 102, 255);\">Avg18:<b>""$average18""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 99, 132);\">Avg38:<b>""$average38""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Avg95:<b>""$average95""€</b></span>"
        echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Tendency:<b>""$tendency""</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 159, 64);\">Stoch14:<b>""$lastStochasticQuoteRounded" "</b></span>"
        echo "&nbsp;<span style=\"color:rgb(54, 162, 235);\">RSI14:<b>""$lastRSIQuoteRounded" "</b></span>"
        echo "&nbsp;<span style=\"color:rgb(255, 205, 86);\">MACD:<b>""$lastMACDValue" "</b></span></p>"

        # Strategies output

        # Sell/Buy
        echo "<p style=\"color:rgb(75, 192, 192);\"><b>" "$resultStrategieByTendency" "</b></p>"
        
        # Buy
        #echo "<p style=\"color:rgb(75, 192, 192);\"><b>" "$resultStrategieUnderratedByTendency" "</b></p>"
        echo "<p style=\"color:rgb(255, 205, 86);\"><b>" "$resultStrategieUnderratedLowHorizontalMACD" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieUnderratedByPercentAndStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieUnderratedXLowStochastic" "</b></p>"
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieUnderratedXLowRSI" "</b></p>"
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieUnderratedLowStochasticLowRSILowMACD" "</b></p>"
        
        # Sell
      #  echo "<p style=\"color:rgb(75, 192, 192);\"><b>" "$resultStrategieOverratedByTendency" "</b></p>"
        echo "<p style=\"color:rgb(255, 205, 86);\"><b>" "$resultStrategieOverratedHighHorizontalMACD" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieOverratedByPercentAndStochastic" "</b></p>"
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieOverratedXHighStochastic" "</b></p>"
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieOverratedXHighRSI" "</b></p>"
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieOverratedHighStochasticHighRSIHighMACD" "</b></p>"
        echo "Good Luck!"

        cat js/indexPart13.html
    } >> "$indexSymbolFile"

    WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$symbol" "$symbolName" "$BLACK" "$markerOwnStock" ""
done

echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE

# Write temp/*.html symbolFile's for later screenshot in github workflow!
rm -rf temp/*.html
# Create a file for later screenshots in workflow, so that there will be no error!
cp "$OUT_RESULT_FILE" temp/1.html
i=1
for symbolFile in $reportedSymbolFileList
do
    cp "$symbolFile" temp/$i.html
    i=$((i + 1))
done
# Maximal 15 hardcoded screenshot. If this value is increased, then increase it in github workflow as well! (swinton/screenshot-website)
while [ "$i" -le 15 ];
do
    touch temp/$i.html
    i=$((i + 1))
done

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Tar 
# shellcheck disable=SC2116,SC2086
reportedSymbolFileList=$(echo $reportedSymbolFileList $OUT_RESULT_FILE)
# shellcheck disable=SC2086
tar -zcf $OUT_ZIP_FILE $reportedSymbolFileList
mv $OUT_ZIP_FILE out
