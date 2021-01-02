#!/bin/sh

# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'ADS *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query over REST API.
# 4. Parameter: RATED - [overrated|underrated|all]. Only list overrated/underrated/all stocks.
# 5. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 6. Parameter: RSI: Quote for RSI indicator (only 30 and less allowed!)
# Call example: ./analyse.sh 'ADS *ALV' 3 online underrated 9 30
# Call example: ./analyse.sh 'ADS' 1 offline underrated 9 30
# Call example: ./analyse.sh '*ADS' 1 offline all 9 30
#
# Set MARKET_STACK_ACCESS_KEY1, MARKET_STACK_ACCESS_KEY2 and MARKET_STACK_ACCESS_KEY3 as Env Variable
# shellcheck disable=SC1091 

# Import functions
. ./script/functions.sh

# Import strategies
. ./script/strategies.sh

# Settings for currency formating with 'printf'
export LC_ALL=en_IN.UTF-8

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
ratedParam=$4
stochasticPercentageParam=$5
RSIQuoteParam=$6

# Prepare
mkdir -p out
mkdir -p temp
OUT_ZIP_FILE=_out.tar.gz
rm -rf out/$OUT_ZIP_FILE
touch out/$OUT_ZIP_FILE
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
reportedSymbolFileList=""
TICKER_NAMES_FILE=data/_ticker_names.txt
HTML_RESULT_FILE_HEADER="<html><head><link rel=\"shortcut icon\" type=\"image/ico\" href=\"_favicon.ico\" /><title>Result</title><style>.colored {color:blue;}#body {font-size: 14px;}@media screen and (min-width: 500px)</style></head><body><div><p>"
echo "$HTML_RESULT_FILE_HEADER" > $OUT_RESULT_FILE
HTML_RESULT_FILE_END="</p><p>Good Luck!</p></div></body></html>"
COMDIRECT_URL_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?timeSpan=6M&chartType=MOUNTAIN&useFixAverage=false&freeAverage0=100&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&ID_NOTATION="
START_TIME_MEASUREMENT=$(date +%s);

# Check for multiple identical symbols in cmd
echo "$symbolsParam" | tr " " "\n" | sort | uniq -c | grep -qv '^ *1 ' && echo "$symbolsParam" | tr " " "\n" | sort | uniq -c  | tee -a $OUT_RESULT_FILE && echo "Multiple symbols in parameter list!!!!!" | tee -a $OUT_RESULT_FILE && echo "<br>" >> $OUT_RESULT_FILE #&& exit 4

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" "$percentageParam" "$queryParam" "$ratedParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE

if [ -z "$MARKET_STACK_ACCESS_KEY1" ] || [ -z "$MARKET_STACK_ACCESS_KEY2" ] || [ -z "$MARKET_STACK_ACCESS_KEY3" ]; then
    echo "Error: MARKET_STACK_ACCESS_KEY1 or MARKET_STACK_ACCESS_KEY2 or MARKET_STACK_ACCESS_KEY3 not set!" | tee -a $OUT_RESULT_FILE
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
echo "Rated:$ratedParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic:$stochasticPercentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI:$RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "<br><br># Workflow Result<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=_blank>Github Action</a><br><br># Comdirect Link<br>" >> $OUT_RESULT_FILE

# Analyse data for each symbol
for symbol in $symbolsParam
do
    # Stocks with prefix '*' are marked as own stocks
    markerOwnStock=""
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        markerOwnStock="*"
        symbol=$(echo "$symbol" | cut -b 2-6)
    fi

    # Curl symbol name with delay of 14sec because of REST API restrictions
    CurlSymbolName "$symbol" $TICKER_NAMES_FILE 14

    # Get stock data
    echo ""
    echo "# Get $symbolName"
    DATA_FILE=temp/${symbol}_data.txt
    rm -rf "$DATA_FILE"
    DATA_DATE_FILE=data/${symbol}.txt
    if [ "$queryParam" = 'online' ]; then
        tag=$(date +"%s") # Second -> date +"%s" ; Day -> date +"%d"
        evenodd=$((tag % 3))
        if [ "$evenodd" -eq 0 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY1}
        fi
        if [ "$evenodd" -eq 1 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY2}
        fi
        if [ "$evenodd" -eq 2 ]; then
            ACCESS_KEY=${MARKET_STACK_ACCESS_KEY3}
        fi
        curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${ACCESS_KEY}&exchange=XETRA&symbols=${symbol}.XETRA" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}' > "$DATA_DATE_FILE"
        fileSize=$(stat -c %s "$DATA_DATE_FILE")
        if [ "${fileSize}" -eq "0" ]; then
            echo "!Symbol NOT found online on marketstack.com: $symbol" | tee -a $OUT_RESULT_FILE
            echo "<br>" >> $OUT_RESULT_FILE
            rm -rf "$DATA_DATE_FILE"
        fi
    fi

    symbolName=$(grep -w "$symbol " $TICKER_NAMES_FILE)

    CreateCmdAnalyseHyperlink

    ProgressBar 1 8

    awk '{print $2}' "$DATA_DATE_FILE" > "$DATA_FILE"
    lastRaw=$(head -n1 "$DATA_FILE")
    last=$(printf "%.2f" "$lastRaw")
    # Check for unknown or not fetched symbol in cmd or on marketstack.com
    if [ "${#lastRaw}" -eq 0 ]; then
        echo "!Symbol $symbol NOT found offline in data/$symbol.txt: Try to query 'online'!" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
        # continue with next symbol in the list
        continue
    fi

    head -n18 "$DATA_FILE" > temp/values18.txt
    average18Raw=$(awk '{ sum += $1; } END { print sum/18; }' < temp/values18.txt)
    average18=$(printf "%.2f" "$average18Raw")

    ProgressBar 2 8

    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average18"; lastOverAgv18=$?
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average18"; lastUnderAgv18=$?

    head -n38 "$DATA_FILE" > temp/values38.txt
    average38Raw=$(awk '{ sum += $1; } END { print sum/38; }' < temp/values38.txt)
    average38=$(printf "%.2f" "$average38Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average38"; lastOverAgv38=$?
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average38";lastUnderAgv38=$?
    
    head -n100 "$DATA_FILE" > temp/values100.txt
    average100Raw=$(awk '{ sum += $1; } END { print sum/100; }' < temp/values100.txt)
    average100=$(printf "%.2f" "$average100Raw")
    GreaterThenWithFactor "$percentageGreaterFactor" "$last" "$average100"; lastOverAgv100=$?
    LesserThenWithFactor "$percentageLesserFactor" "$last" "$average100"; lastUnderAgv100=$?

    # Averages
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average38"; agv18OverAgv38=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average18" "$average38"; agv18UnderAgv38=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average38" "$average100"; agv38OverAgv100=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average38" "$average100"; agv38UnderAgv100=$?
    GreaterThenWithFactor "$percentageGreaterFactor" "$average18" "$average100"; agv18OverAgv100=$?
    LesserThenWithFactor "$percentageLesserFactor" "$average18" "$average100"; agv18UnderAgv100=$?
 
    ProgressBar 3 8

    # Calculate RSI 14 values
    RSIInDays14=14
    lastRSIQuoteRounded=""
    RSIQuoteList=""
    RSIOfDays $RSIInDays14 "$DATA_FILE"

    ProgressBar 4 8

    # Calculate Stochastic 14 values
    stochasticInDays14=14
    lastStochasticQuoteRounded=""
    stochasticQuoteList=""
    StochasticOfDays $stochasticInDays14 "$DATA_FILE"

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

    # Average 100
    averageInDays100=100
    averagePriceList=""
    AverageOfDays $averageInDays100 "$DATA_FILE"
    averagePriceList100=$averagePriceList

    ProgressBar 8 8
    
    #
    # Apply strategies
    #

    # Valid data is more then 200kb. Oherwise data might be damaged or unsufficiant
    fileSize=$(stat -c %s "$DATA_FILE")
    if [ "$fileSize" -gt 200 ]; then

        # + Strategie: UnderratedByPercentAndStochastic
        resultStrategieUnderratedByPercentAndStochastic=""
        StrategieUnderratedByPercentAndStochastic "$ratedParam" "$lastStochasticQuoteRounded" "$stochasticPercentageLower" "$lastUnderAgv18" "$lastUnderAgv38" "$lastUnderAgv100" "$agv18UnderAgv38" "$agv38UnderAgv100" "$agv18UnderAgv100" "$last" "$percentageGreaterFactor" "$average18" "$average38" "$average100" "$stochasticPercentageLower" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"
    
        # + Strategie: Low stochastic 3 last values under lowStochasticValue
        resultStrategieUnderrated3LowStochastic=""
        StrategieUnderrated3LowStochastic "$ratedParam" "$stochasticPercentageLower" "$stochasticQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # + Strategie: Low stochastic and Low RSI last quote under lowRSIValue
        resultStrategieUnderratedLowStochasticLowRSI=""
        StrategieUnderratedLowStochasticLowRSI "$ratedParam" "$stochasticPercentageLower" "$RSIQuoteLower" "$lastStochasticQuoteRounded" "$lastRSIQuoteRounded" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # - Strategie: OverratedByPercentAndStochastic
        resultStrategieOverratedByPercentAndStochastic=""
        StrategieOverratedByPercentAndStochastic "$ratedParam" "$lastStochasticQuoteRounded" "$stochasticPercentageUpper" "$lastOverAgv18" "$lastOverAgv38" "$lastOverAgv100" "$agv18OverAgv38" "$agv38OverAgv100" "$agv18OverAgv100" "$last" "$percentageLesserFactor" "$average18" "$average38" "$average100" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # - Strategie: Overrated3HighStochastic
        resultStrategieOverrated3HighStochastic=""
        StrategieOverrated3HighStochastic "$ratedParam" "$stochasticPercentageUpper" "$stochasticQuoteList" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

        # + Strategie: High stochastic and High RSI last quote over lowRSIValue
        resultStrategieOverratedHighStochasticHighRSI=""
        StrategieOverratedHighStochasticHighRSI "$ratedParam" "$stochasticPercentageUpper" "$RSIQuoteUpper" "$lastStochasticQuoteRounded" "$lastRSIQuoteRounded" $OUT_RESULT_FILE "$symbol" "$symbolName" "$markerOwnStock"

    else
        # shellcheck disable=SC3037
        echo -e "\n\r! File sizeof $symbol id suspicious: $fileSize kb" | tee -a $OUT_RESULT_FILE
        echo "<br>" >> $OUT_RESULT_FILE
    fi

    #
    # Output
    #

    indexSymbolFile=out/${symbol}.html
    rm -rf "$indexSymbolFile"
    cp js/_favicon.ico out

    {
        cat js/indexPart0.html 
        echo "${symbol}" 
        cat js/indexPart1.html 
        echo "'" "${symbolName}" "',"
        cat js/indexPart2.html
    
        # Writing chart ${symbol}.html
        commaPriceList=$(awk '{ print $1","; }' < "$DATA_FILE" | tac)
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

        echo "'" Average $averageInDays100 "'," 
        cat js/indexPart8.html 
        echo "$averagePriceList100" 
        cat js/indexPart9.html 

        echo "$stochasticQuoteList" 
        cat js/indexPart10.html 

        echo "$RSIQuoteList" 
        cat js/indexPart11.html 

        # Color result link in Chart
        styleComdirectLink="style=\"font-size:x-large; color:black\""
        if [ "${#resultStrategieOverratedByPercentAndStochastic}" -gt 1 ] || [ "${#resultStrategieOverrated3HighStochastic}" -gt 1 ] || [ "${#resultStrategieOverratedHighStochasticHighRSI}" -gt 1 ]; then
            styleComdirectLink="style=\"font-size:x-large; color:red\""
        fi 
        if [ "${#resultStrategieUnderratedByPercentAndStochastic}" -gt 1 ] || [ "${#resultStrategieUnderrated3LowStochastic}" -gt 1 ] || [ "${#resultStrategieUnderratedLowStochasticLowRSI}" -gt 1 ]; then
            styleComdirectLink="style=\"font-size:x-large; color:green\""
        fi
        ID_NOTATION=$(grep "${symbol}" data/_ticker_idnotation.txt | cut -f 2 -d ' ')
        echo "<p><a $styleComdirectLink href=""$COMDIRECT_URL_PREFIX""$ID_NOTATION" " target=_blank>$markerOwnStock$symbolName</a><br>" 
        echo "Percentage:<b>$percentageParam</b> " 
        echo "Query:<b>$queryParam</b> " 
        echo "Rated:<b>$ratedParam</b> " 
        echo "Stochastic14:<b>$stochasticPercentageParam</b> " 
        echo "RSI14:<b>$RSIQuoteParam</b><br>" 

        # Plausi quote day from last trading day
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
            echo "Date:<b>$quoteDate </b>" # OK, quote from last trading day
        else
            echo "Date:<b style=\"color:red; font-size:xx-large;\">$quoteDate </b>" 
        fi
        echo "&nbsp;<span style=\"color:rgb(0, 0, 0);\">Last price:<b>""$last" "&#8364;</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(153, 102, 255);\">Avg18:<b>""$average18" "&#8364;</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(255, 99, 132);\">Avg38:<b>""$average38" "&#8364;</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(75, 192, 192);\">Avg100:<b>""$average100" "&#8364;</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(255, 159, 64);\">Stoch14:<b>""$lastStochasticQuoteRounded" "</b></span>" 
        echo "&nbsp;<span style=\"color:rgb(54, 162, 235);\">RSI14:<b>""$lastRSIQuoteRounded" "</b></span></p>" 

        # Strategies output
        # + buy
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieUnderratedByPercentAndStochastic" "</b></p>" 
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieUnderrated3LowStochastic" "</b></p>" 
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieUnderratedLowStochasticLowRSI" "</b></p>" 
        
        # - sell
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieOverratedByPercentAndStochastic" "</b></p>" 
        echo "<p style=\"color:rgb(255, 159, 64);\"><b>" "$resultStrategieOverrated3HighStochastic" "</b></p>" 
        echo "<p style=\"color:rgb(54, 162, 235);\"><b>" "$resultStrategieOverratedHighStochasticHighRSI" "</b></p>" 
             
        echo "Good Luck!"

        cat js/indexPart12.html
    } >> "$indexSymbolFile"

    WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$symbol" "$symbolName" false black "$markerOwnStock"
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
# Maximal 5 hardcoded screenshot. If this value is increased, then increase it in github workflow as well! (swinton/screenshot-website)
while [ "$i" -le 5 ];
do
    touch temp/$i.html
    i=$((i + 1))
done

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."

# Cleanup
rm -rf temp/values*.txt
rm -rf temp/*_data.txt
# shellcheck disable=SC2116,SC2086
reportedSymbolFileList=$(echo $reportedSymbolFileList $OUT_RESULT_FILE)
# shellcheck disable=SC2086
tar -zcf $OUT_ZIP_FILE $reportedSymbolFileList
mv $OUT_ZIP_FILE out
