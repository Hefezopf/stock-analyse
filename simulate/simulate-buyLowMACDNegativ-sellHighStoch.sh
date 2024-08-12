#!/bin/bash

# This script simulates a given stock quote.
# Call: simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE SELL_IF_OVER_PERCENTAGE KEEP_IF_UNDER_PERCENTAGE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# NOT USED!!! -----# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# 7. Parameter: KEEP_IF_UNDER_PERCENTAGE: Keep if position is under this value: like 1 means 1% or more gain -> not sell.
# 8. Parameter: ALARM_COUNT_FOR_STOCK: Buy, if count is true for alarm. Like: 'C+4R+7S+P+D+N+M+' = 7 times '+'
# 9. Parameter: ALARM_COUNT_FOR_INDEX: Buy, if count is true for alarm. Like: '7S+P+D+N+M+' = 5 times '+'
# Call example: simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh 'BEI' 2500 13 70 1.1 5 2 7 5
# Call example: simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2000 25 91 1.1 5 1 7 5
# Call example: simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2500 14 65 1.05 5 2 7 5

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StochSellLevelParam=$4
incrementPerTradeParam=$5
sellIfOverPercentageParam=$6 # NOT USED!!!
keepIfUnderPercentageParam=$7
alarmCountForStockParam=$8
alarmCountForIndexParam=$9
alarmCountForIndexOrigParam=$9 # Copy as orig. value needed for summary at the end

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

OUT_SIMULATE_FILE="simulate/out/_simulate.html"
QUOTE_MAX_VALUE=999999
ARRAY_BUY_POS_SIM=()

function ParameterOut()
{
    #Out "!!! DATA_DIR:$DATA_DIR" $OUT_SIMULATE_FILE
    Out "Amount Per Trade:$amountPerTradeParam€" $OUT_SIMULATE_FILE
    Out "RSI Buy Level:$RSIBuyLevelParam" $OUT_SIMULATE_FILE
    Out "Stoch Sell Level:$StochSellLevelParam" $OUT_SIMULATE_FILE
    Out "Increment Per Trade:$incrementPerTradeParam" $OUT_SIMULATE_FILE
    Out "Sell Over Percentage:$sellIfOverPercentageParam" $OUT_SIMULATE_FILE
    Out "Keep Under Percentage:$keepIfUnderPercentageParam" $OUT_SIMULATE_FILE
    Out "Buy Alarm count for Stocks:$alarmCountForStockParam" $OUT_SIMULATE_FILE
    Out "Buy Alarm count for Indexes:$alarmCountForIndexOrigParam" $OUT_SIMULATE_FILE
}

mkdir -p simulate/out
sellAmountOverAll=0
sellOnLastDayAmountOverAll=0
averageHoldingDaysOverallDays=0
averageHoldingDaysOverallSymbols=0
export alarmAbbrevTemplate # from functions.sh
export winOverall=0
export _outputText=""
export txFee

# shellcheck disable=SC2140
echo "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8' /><link rel='shortcut icon' type='image/ico' href='favicon.ico' /><title>Simulate</title></head><body>" >> $OUT_SIMULATE_FILE

Out "" $OUT_SIMULATE_FILE
Out "# SA Simulate" $OUT_SIMULATE_FILE
Out "############" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))

Out "Symbols($countSymbols):$symbolsParam" $OUT_SIMULATE_FILE

ParameterOut

echo "<br><button id='buttonGoToEnd' style='font-size:large; height: 60px; width: 118px;' type='button' onclick='function doGoToEnd(){var scrollingElement = (document.scrollingElement || document.body);scrollingElement.scrollTop = scrollingElement.scrollHeight;};doGoToEnd()'>GoTo End</button>" >> $OUT_SIMULATE_FILE
echo "&nbsp;<a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate.html\" target=\"_blank\">Simulation</a><br>" >> $OUT_SIMULATE_FILE

# Simulate stock for each symbol
for symbol in $symbolsParam
do
    ARRAY_TX_INDEX=()
    ARRAY_TX_BUY_PRICE=({} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {})
    ARRAY_TX_SELL_PRICE=({} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {})
    amountOfTrades=0
    buyingDay=0
    wallet=0
    simulationWin=0
    piecesHold=0
    intermediateProzWin=0
    amountPerTrade=$amountPerTradeParam

    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-7)
    fi

    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)

    Out "" $OUT_SIMULATE_FILE

    CreateCmdHyperlink "Simulation" "simulate/out" "$symbol" #"$symbolName"

    # Market Cap
    marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    lowMarketCapLinkBackgroundColor="white"
    if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
        lowMarketCapLinkBackgroundColor="rgba(251, 225, 173)"
    fi
    echo "<a style='background:$lowMarketCapLinkBackgroundColor;' href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/""$symbol"".html $symbolName\" target=\"_blank\">$_outputText</a><br>" >> $OUT_SIMULATE_FILE
    

    #DATA_FILE=data/"$symbol".txt
    #DATA_FILE="$DATA_DIR/$symbol".txt
    #dateOfFile=$(head -n1 "$DATA_FILE" | tail -1 | cut -f 1)
    #ALARM_FILE=alarm/"$symbol"_"$dateOfFile".txt
    ALARM_FILE=alarm/"$symbol".txt
    alarms=$(head "$ALARM_FILE")
    HISTORY_FILE=history/"$symbol".txt
    historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
    historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)
    historyRSIs=$(head -n6 "$HISTORY_FILE" | tail -1)
    historyMACDs=$(head -n8 "$HISTORY_FILE" | tail -1)
    
    historyMACDs=$(echo "$historyMACDs" | cut -b 64-10000)
    RSIindex=26
    valueNewMACDLow=100
    valueMACDLast_3="-1" 
    valueMACDLast_2="-1" 
    valueMACDLast_1="-1" 
    valueMACDLast_0="-1"
    beforeLastQuote="$QUOTE_MAX_VALUE"
    # shellcheck disable=SC2001
    for valueMACD in $(echo "$historyMACDs" | sed "s/,/ /g")
    do
        ARRAY_TX_BUY_PRICE[RSIindex]="{}"
        ARRAY_TX_SELL_PRICE[RSIindex]="{}"
        valueMACDLast_3="$valueMACDLast_2" 
        valueMACDLast_2="$valueMACDLast_1" 
        valueMACDLast_1="$valueMACDLast_0" 
        valueMACDLast_0="$valueMACD" 

        isMACDHorizontalAlarm=false
        isNewMACDLower=$(echo "$valueMACD" "$valueNewMACDLow" | awk '{if ($1 <= $2) print "true"; else print "false"}')
        #if [ "$(echo "$valueMACD <= $valueNewMACDLow" | bc)" ]; then
        if [ "$isNewMACDLower" = true ]; then
            valueNewMACDLow="$valueMACD"
            isNegativMACDLast_0=${valueMACDLast_0:0:1}
            isNegativMACDLast_1=${valueMACDLast_1:0:1}
            isNegativMACDLast_2=${valueMACDLast_2:0:1}
            isNegativMACDLast_3=${valueMACDLast_3:0:1}
            if [ "$isNegativMACDLast_0" = '-' ] && [ "$isNegativMACDLast_1" = '-' ] && [ "$isNegativMACDLast_2" = '-' ] && [ "$isNegativMACDLast_3" = '-' ]; then
                isMACDHorizontalAlarm=true
            fi
        fi 

        # isNewLow
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        isNewLow=$(echo "$quoteAt" "$beforeLastQuote" | awk '{if ($1 < $2) print "true"; else print "false"}')

#echo isNewLow $isNewLow quoteAt $quoteAt beforeLastQuote $beforeLastQuote

        if [ "$isNewLow" = true ]; then
            beforeLastQuote="$quoteAt"
        fi

        if [ "${#ARRAY_BUY[@]}" -gt 0 ]; then
            isBuyArrayFilled=true
        else
            isBuyArrayFilled=false
        fi

        # lastStoch
        lastStoch="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 

        # lastRSI
        lastRSI="$(echo "$historyRSIs" | cut -f "$RSIindex" -d ',')" 

        # Allways buy, if allready hold pieces and new low
        if [ "$isBuyArrayFilled" = true ] && [ "$piecesHold" -gt 0 ] && [ "$isNewLow" = true ]; then
            isHoldPiecesAndNewLow=true
        else
            isHoldPiecesAndNewLow=false
        fi 

        # is MACD horizontal and lastStoch?
        if [ "$isMACDHorizontalAlarm" = true ] && [ "$isNewLow" = true ] && [ "$lastStoch" = 0 ] && [ "$lastRSI" -le "$RSIBuyLevelParam" ]; then
            isMACDhorizontalAndLastStochNeg=true
        else
            isMACDhorizontalAndLastStochNeg=false
        fi

        posInAlarm=$((RSIindex-13))
        alarmAtIndex="$(echo "$alarms" | cut -f "$posInAlarm" -d ',')"
        _amountOfBuySignals="${alarmAtIndex//[^+]}"
        # Buy, if more buy signals in Result file: STOCK >= 7 or INDEX >=5
        if { [ "${#_amountOfBuySignals}" -ge "$alarmCountForStockParam" ] && [ "$asset_type" = 'STOCK' ]; } || 
            { [ "${#_amountOfBuySignals}" -ge "$alarmCountForIndexParam" ] && [ "$asset_type" = 'INDEX' ]; } then
            isHoldPiecesAndNewLow=true
            isMACDhorizontalAndLastStochNeg=true
        fi

        # Buy
        if [ "$isHoldPiecesAndNewLow" = true ] || [ "$isMACDhorizontalAndLastStochNeg" = true ]; then
            CalculateMarketCapRSILevel "$lastRSI" "$marketCapFromFile"
            # shellcheck disable=SC2154
            if [ "$isMarketCapRSILevel" = true ]; then
                marketCapFromFile=10000 # Make CalculateMarketCapRSILevel() allways true in the following caluculations
                alarmCountForStockParam=$8
                alarmCountForIndexParam=100
                piecesPerTrade=$(echo "$amountPerTrade $quoteAt" | awk '{print ($1 / $2)}')
                amountPerTrade=$(echo "$amountPerTrade $incrementPerTradeParam" | awk '{print ($1 * $2)}')
                piecesPerTrade=${piecesPerTrade%.*}
                if [ "$piecesPerTrade" -eq 0 ]; then
                    piecesPerTrade=1
                fi

                amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
                amount=$(printf "%.0f" "$amount")

                # Fees each Buy trade
                CalculateTxFee "$quoteAt" "$piecesPerTrade"
                amount=$((amount - txFee))
              
                piecesHold=$((piecesHold+piecesPerTrade))
                wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
                wallet=$(printf "%.0f" "$wallet")
                quoteAt=$(printf "%.2f" "$quoteAt")
                Out "Buy\tPos:$RSIindex\t""$piecesPerTrade""Pc\tQuote:$quoteAt€\tAmount:$amount€\tMACD:$valueMACD\tPieces:$piecesHold\tWallet:$wallet€" $OUT_SIMULATE_FILE
                buyingDay=$((buyingDay + RSIindex))
                amountOfTrades=$((amountOfTrades + 1))

                # Calculate ARRAY_BUY
                for i in "${!ARRAY_BUY[@]}"; do
                    if [ "$i" -eq "$RSIindex" ]; then
                        valueArray="${ARRAY_BUY[i]}"
                        if [ "${ARRAY_BUY[i]}" = '' ]; then
                            Out "SHOUD NOT HAPPEN" $OUT_SIMULATE_FILE
                            valueArray=0
                        fi
                        amount=$(echo "$valueArray $amount" | awk '{print ($1 + $2)}')
                    fi
                done

                if [ "$RSIindex" -eq 100 ]; then
                    ARRAY_BUY_POS_SIM+=("$symbol")
                fi

                ARRAY_BUY[RSIindex]=$amount
                ARRAY_TX_INDEX[RSIindex]="$wallet€"
                ARRAY_TX_BUY_PRICE[RSIindex]="{x:1,y:$quoteAt,r:10}"
            fi
        fi

        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        if [ "$piecesHold" -gt 0 ]; then
            # 20 Euro Fees each Sell trade
            amount=$(echo "$quoteAt $piecesHold 20" | awk '{print ($1 * $2) - $3}')
            amount=$(printf "%.0f" "$amount")
            quoteAt=$(printf "%.2f" "$quoteAt")
            averageBuyingDay=$(echo "$buyingDay $amountOfTrades" | awk '{print ($1 / $2)}')
            averageHoldingDays=$(echo "$RSIindex $averageBuyingDay" | awk '{print ($1 - $2)}')
            averageHoldingDays=$(printf "%.1f" "$averageHoldingDays")
            intermediateProzWin=$(echo "$amount $wallet" | awk '{print (($1 / $2 * 100)-100)}')
            intermediateProzWin=$(printf "%.1f" "$intermediateProzWin")
            intermediateProzWinFirstDigit=${intermediateProzWin:0:1}
            intermediateProzWinSecondDigit=${intermediateProzWin:1:1}
            if [ "$intermediateProzWinFirstDigit" = '-' ]; then 
                intermediateProzWinFirstDigit=0
            else 
                # Special cases: if gains are 2 Number digits like (11.1%, 22.1%, 33.1%, 44.1, or 55.1)
                if [ "$intermediateProzWinFirstDigit" -eq 5 ] && [ ! "$intermediateProzWinSecondDigit" = "." ]; then
                    intermediateProzWinFirstDigit="${intermediateProzWinFirstDigit}${intermediateProzWinSecondDigit}"
                fi
                if [ "$intermediateProzWinFirstDigit" -eq 4 ] && [ ! "$intermediateProzWinSecondDigit" = "." ]; then
                    intermediateProzWinFirstDigit="${intermediateProzWinFirstDigit}${intermediateProzWinSecondDigit}"
                fi
                if [ "$intermediateProzWinFirstDigit" -eq 3 ] && [ ! "$intermediateProzWinSecondDigit" = "." ]; then
                    intermediateProzWinFirstDigit="${intermediateProzWinFirstDigit}${intermediateProzWinSecondDigit}"
                fi
                if [ "$intermediateProzWinFirstDigit" -eq 2 ] && [ ! "$intermediateProzWinSecondDigit" = "." ]; then
                    intermediateProzWinFirstDigit="${intermediateProzWinFirstDigit}${intermediateProzWinSecondDigit}"
                fi
                if [ "$intermediateProzWinFirstDigit" -eq 1 ] && [ ! "$intermediateProzWinSecondDigit" = "." ]; then
                    intermediateProzWinFirstDigit="${intermediateProzWinFirstDigit}${intermediateProzWinSecondDigit}"
                fi
            fi
            # Sell if over Percentage Param (5%) or, if over Stoch Level Param (70)
            if [ "$stochAt" -gt "$StochSellLevelParam" ]; then
            #if [ "$intermediateProzWinFirstDigit" -gt "$sellIfOverPercentageParam" ] || [ "$stochAt" -gt "$StochSellLevelParam" ]; then
                isIntermediateProzWinNegativ=${intermediateProzWin:0:1}
                # NOT Sell, if tx would be a negative trade
                if [ ! "$isIntermediateProzWinNegativ" = '-' ]; then
                    # ONLY Sell, if gain percent is over KEEP_IF_UNDER_PERCENTAGE (1%)
                    if [ "$intermediateProzWinFirstDigit" -gt "$keepIfUnderPercentageParam" ]; then
                        wallet=$((amount-wallet))
                        wallet=$(printf "%.0f" "$wallet")
                        sellAmountOverAll=$((amount+sellAmountOverAll))
                        
                        Out "Sell\tPos:$RSIindex\t""$piecesHold""pc\tQuote:$quoteAt€\tAmount:$amount€\tStoch:$stochAt" $OUT_SIMULATE_FILE
                        anualPercentWin=$(echo "360 $averageHoldingDays" | awk '{print ($1 / $2)}')
                        anualPercentWin=$(echo "$anualPercentWin $intermediateProzWin" | awk '{print ($1 * $2)}')
                        anualPercentWin=$(printf "%.0f" "$anualPercentWin")
                        Out "Intermediate Win=$wallet€ Perc=$intermediateProzWin% Estimated AnualPerc=$anualPercentWin% Avg Holding Busi.Days=$averageHoldingDays Days" $OUT_SIMULATE_FILE

                        averageHoldingDaysOverallDays=$(echo "$averageHoldingDaysOverallDays $averageHoldingDays" | awk '{print ($1 + $2)}')
                        averageHoldingDaysOverallSymbols=$((averageHoldingDaysOverallSymbols + 1))
                        averageHoldingDaysOverall=$(echo "$averageHoldingDaysOverallDays $averageHoldingDaysOverallSymbols" | awk '{print ($1 / $2)}')
                        #echo averageHoldingDaysOverallDays=$averageHoldingDaysOverallDays averageHoldingDaysOverallSymbols=$averageHoldingDaysOverallSymbols averageHoldingDaysOverall=$averageHoldingDaysOverall

                        simulationWin=$((simulationWin+wallet))
                        piecesHold=0
                        amountPerTrade="$amountPerTradeParam"
                        amountOfTrades=0
                        buyingDay=0
                        RSIBuyLevelParam=$3
                        # Reset MACD
                        valueNewMACDLow=100
                        # Reset MarketCap
                        marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)

                        # Calculate ARRAY_SELL
                        for i in "${!ARRAY_SELL[@]}"; do
                            if [ "$i" -eq "$RSIindex" ]; then
                                valueArray="${ARRAY_SELL[i]}"
                                if [ "${ARRAY_SELL[i]}" = '' ]; then
                                    valueArray=0
                                fi
                                amount=$(echo "$valueArray $amount" | awk '{print ($1 + $2)}')
                            fi
                        done
                        ARRAY_SELL[RSIindex]=$amount
                        ARRAY_TX_INDEX[RSIindex]="+$wallet€+$intermediateProzWin%"
                        ARRAY_TX_SELL_PRICE[RSIindex]="{x:1,y:$quoteAt,r:10}"

                        wallet=0
                    fi
                fi
            fi
        fi

        # Reset MACD (and beforeLastQuote) at RSI Schwellwert 40
        if [ "$lastRSI" -gt 40 ] && [ "$piecesHold" -eq 0 ]; then
            valueNewMACDLow=100
            beforeLastQuote="$QUOTE_MAX_VALUE"
        fi

        RSIindex=$((RSIindex + 1))
    done

    # Sell all on the last day, to get gid of all stocks for simulation
    if [ "$piecesHold" -gt 0 ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f 100 -d ',')" 
        Out "Keep on the last day!!" $OUT_SIMULATE_FILE
        # 30 Euro Fees each Last Day Sell trade
        amount=$(echo "$quoteAt $piecesHold 30" | awk '{print ($1 * $2) - $3}')
        amount=$(printf "%.0f" "$amount")
        quoteAt=$(printf "%.2f" "$quoteAt")
        percentageLost=$(echo "$wallet $amount" | awk '{print (100-(100 / $1 * $2 ))*(-1)}')
        percentageLost=$(printf "%.1f" "$percentageLost")
        #percentageLost=$(printf "%.2f" "$percentageLost")
        Out "Keep\tPos:100\t""$piecesHold""pc\tQuote:$quoteAt€\tCurrent Value=$amount€\tPerc=$percentageLost%" $OUT_SIMULATE_FILE
        sellOnLastDayAmountOverAll=$(echo "$sellOnLastDayAmountOverAll $amount" | awk '{print ($1 + $2)}')
       # lastLowestQuoteAt=$QUOTE_MAX_VALUE 
        RSIBuyLevelParam=$3
    fi

    isSimulationWinNull=${simulationWin:0:1}
    simulationWin=$(printf "%.0f" "$simulationWin")
    if [ ! "$isSimulationWinNull" = '0' ]; then
        Out "--------------------------" $OUT_SIMULATE_FILE
        Out "Simulation Win=$simulationWin€" $OUT_SIMULATE_FILE
        winOverAll=$((winOverAll+simulationWin))
        prozSimulationWinOverAll=$(echo "$simulationWin $sellAmountOverAll" | awk '{print (($1 / $2 * 100))}')
        prozSimulationWinOverAll=$(printf "%.1f" "$prozSimulationWinOverAll")
    fi

    # Copy HTML file: out -> simulate/out
    cp out/"$symbol".html simulate/out/"$symbol".html

    # Write/Replace X-Axis
    xAxis="$alarmAbbrevTemplate"",'100'"
    for i in "${!ARRAY_TX_INDEX[@]}"; do
        # Buy may replace some Sell-XXX values -> looks strange: 'SELL-9BUY
        # shellcheck disable=SC2001
        xAxis=$(echo "$xAxis" | sed "s/'$i'/'${ARRAY_TX_INDEX[i]}'/g")
    done
    # sed -i "/labels: /c\labels: [$xAxis" simulate/out/"$symbol".html
    labelsTemplate="labels:[$xAxis"
    #labelsTemplate="$xAxis"
    # ATTENTION Line number may change, if there will be development!
    sed -i "81s/.*/$labelsTemplate/" simulate/out/"$symbol".html    
 
    # Write/Replace "buy"
    buySequenceReplaced="{},{},{},{},{},{},{},{},{},{},{},{},"
    for i in "${!ARRAY_TX_BUY_PRICE[@]}"; do
        if [ "$i" -ge '26' ]; then
            buySequenceReplaced="$buySequenceReplaced${ARRAY_TX_BUY_PRICE[i]},"
        fi
    done
    # Write/Replace simulation "buy" values
    # ATTENTION Line number may change, if there will be development!
    sed -i "182s/.*/$buySequenceReplaced/" simulate/out/"$symbol".html    

    # Write/Replace "sell"
    sellSequenceReplaced="{},{},{},{},{},{},{},{},{},{},{},{},"
    for i in "${!ARRAY_TX_SELL_PRICE[@]}"; do
        if [ "$i" -ge '26' ]; then
            sellSequenceReplaced="$sellSequenceReplaced${ARRAY_TX_SELL_PRICE[i]},"
        fi
    done
    # Write/Replace simulation "sell" values. Replace line!
    # ATTENTION Line number may change, if there will be development!
    sed -i "189s/.*/$sellSequenceReplaced/" simulate/out/"$symbol".html

    if [ "$piecesHold" -gt 0 ]; then
        currentAvg=$(echo "$wallet $piecesHold" | awk '{print ($1 / $2)}')
    else 
        currentAvg="$quoteAt"
    fi
    # Write/Replace simulation "Buying/Last" values. Replace line!
    # ATTENTION Line number may change, if there will be development!
    dataTemplate="data:[X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,]},"
    buyingAvgSequenceReplaced=$(echo -n "$dataTemplate" | sed "s/X/${currentAvg}/g")
    sed -i "217s/.*/$buyingAvgSequenceReplaced/" simulate/out/"$symbol".html

    # Draw 5% over buying/last quote
    percentOverBuyingAvg=$(echo "$currentAvg 1.05" | awk '{print $1 * $2}')
    # Write/Replace simulation "Draw 5% over BuyingAvg" values. Replace line!
    # ATTENTION Line number may change, if there will be development!
    percentOverBuyingAvgSequenceReplaced=$(echo -n "$dataTemplate" | sed "s/X/${percentOverBuyingAvg}/g")
    sed -i "223s/.*/$percentOverBuyingAvgSequenceReplaced/" simulate/out/"$symbol".html

    # Write/Replace timestamp. Replace line!
    creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
    if [ "$(uname)" = 'Linux' ]; then
     # creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # +2h Winterzeit / Wintertime
     #creationDate=$(TZ=EST-0EDT date +"%e-%b-%Y %R") # +1h Sommerzeit / Summertime
     creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # Sommerzeit / Summertime
    fi
    GOOD_LUCK="<br>Good Luck! $creationDate"
    # ATTENTION Line number may change, if there will be development!
    lineNumer=$(grep -wn "Good Luck!" out/"$symbol".html | cut -d: -f1)
    sed -i """$lineNumer""s/.*/$GOOD_LUCK/" simulate/out/"$symbol".html
    #sed -i "580s/.*/$GOOD_LUCK/" simulate/out/"$symbol".html
done

Out "" $OUT_SIMULATE_FILE

for i in "${!ARRAY_SELL[@]}"; do
    ARRAY_DIFF[i]="-${ARRAY_SELL[i]}"
done

# Copy all into Diff Array
for i in "${!ARRAY_BUY[@]}"; do
    ARRAY_DIFF[i]="${ARRAY_BUY[i]}"
    for j in "${!ARRAY_SELL[@]}"; do
        if [ "$i" -eq "$j" ]; then
            valueBuyArray="${ARRAY_BUY[i]}"
            valueSellArray="${ARRAY_SELL[i]}"
            amount=$(echo "$valueBuyArray $valueSellArray" | awk '{print ($1 - $2)}')
            ARRAY_DIFF[i]=$amount
        fi
    done
done

liquidity=0
# Output Liquidity
for i in "${!ARRAY_DIFF[@]}"; do
    valueDiffArray="${ARRAY_DIFF[i]}"
    liquidity=$((liquidity-valueDiffArray))
    Out "$i Liquidity:$liquidity€" $OUT_SIMULATE_FILE
done

isLiquidityNegativ=${isLiquidityNegativ:0:1}
if [ "$isLiquidityNegativ" = '-' ]; then
    Out "Currently invested (in Stocks):$liquidity€" $OUT_SIMULATE_FILE
else
    Out "Currently Liquidity Cash to spend:$liquidity€" $OUT_SIMULATE_FILE
fi

Out "" $OUT_SIMULATE_FILE
Out "# Buy now" $OUT_SIMULATE_FILE

#echo "<script>var linkMap = new Map();</script>" >> $OUT_SIMULATE_FILE

echo "<script>
var linkMap = new Map();
// Hover Chart
function showChart(timeSpan, symbol) { // function is ALLMOST!!! (symbol parameter) redundant in result html and detail html file! (template\indexPart12.html)
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'block';
    //elementSpanToReplace.style.left = '17%'; 
    elementSpanToReplace.style.left = '500px'; 
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan; // Concat is not clean, but works!

}

function hideChart(symbol) {  // function is ALLMOST!!! (symbol parameter) redundant in result html and detail html file! (template\indexPart12.html)
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'none';
}
</script>" >> $OUT_SIMULATE_FILE

echo "<br><button id='buttonOpenAllInTab' style='font-size:large; height: 60px; width: 118px;' type='button' onclick='function doOpenAllInTab(){for (let [key, value] of linkMap) {window.open(value, \"_blank\").focus();}};doOpenAllInTab()'>Open All</button><br><br>" >> $OUT_SIMULATE_FILE
for value in "${ARRAY_BUY_POS_SIM[@]}"
do
    lineFromTickerFile=$(grep -m1 -P "^$value\t" "$TICKER_NAME_ID_FILE")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
id_notation=$(echo "$lineFromTickerFile" | cut -f 3)
    marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    lowMarketCapLinkBackgroundColor="white"
    if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
        lowMarketCapLinkBackgroundColor="rgba(251, 225, 173)"
    fi



{
#    echo "<img class='imgborder' id='imgToReplace$value' alt='' loading='lazy' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$id_notation&TIME_SPAN=10D' style='display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);'/>"
    echo "<img class='imgborder' id='imgToReplace$value' alt='' loading='lazy' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$id_notation&TIME_SPAN=10D' style='display:none;position:fixed;top:50%;left:50%;transform:translate(-65%,-50%);'/>"
    COMDIRECT_URL_10D="$COMDIRECT_URL_STOCKS_PREFIX_10D"
    COMDIRECT_URL_6M="$COMDIRECT_URL_STOCKS_PREFIX_6M"
    COMDIRECT_URL_5Y="$COMDIRECT_URL_STOCKS_PREFIX_5Y"
    # shellcheck disable=SC2154
    if [ "$asset_type" = 'INDEX' ]; then
        COMDIRECT_URL_10D="$COMDIRECT_URL_INDEX_PREFIX_10D"
        COMDIRECT_URL_6M="$COMDIRECT_URL_INDEX_PREFIX_6M"
        COMDIRECT_URL_5Y="$COMDIRECT_URL_INDEX_PREFIX_5Y"
    fi
    echo "<a id='headlineLink$value' style='background:$lowMarketCapLinkBackgroundColor'; onmouseover=\"javascript:showChart('10D', '$value')\" onmouseout=\"javascript:hideChart('$value')\" href='$COMDIRECT_URL_10D$id_notation' target='_blank'>$value $symbolName</a>"
    #echo "<a style='background:$lowMarketCapLinkBackgroundColor';  onmouseover=\"javascript:showChart('6M', '$value')\" onmouseout=\"javascript:hideChart('$value')\" href='$COMDIRECT_URL_6M$id_notation' target='_blank'>&nbsp;6M&nbsp;</a>"
    #echo "<a style='background:$lowMarketCapLinkBackgroundColor'; onmouseover=\"javascript:showChart('5Y', '$value')\" onmouseout=\"javascript:hideChart('$value')\" href='$COMDIRECT_URL_5Y$id_notation' target='_blank'>&nbsp;5Y&nbsp;</a>"

    echo "<a style='background:$lowMarketCapLinkBackgroundColor;' href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/""$value"".html\" target=\"_blank\">SIM</a><br>" >> $OUT_SIMULATE_FILE
} >> "$OUT_SIMULATE_FILE"



    echo "$value"
    # shellcheck disable=SC2027,SC2086
    echo "<script>linkMap.set(\""$value"\", \"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/""$value"".html\");</script>" >> $OUT_SIMULATE_FILE
done

Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
ParameterOut
Out "==========================" $OUT_SIMULATE_FILE
sellAmountOverAll=$(printf "%.0f" "$sellAmountOverAll")
Out "Sell Amount Overall=$sellAmountOverAll€" $OUT_SIMULATE_FILE
sellOnLastDayAmountOverAll=$(printf "%.0f" "$sellOnLastDayAmountOverAll")
Out "Still in Portfolio After Last Day=$sellOnLastDayAmountOverAll€" $OUT_SIMULATE_FILE
averageHoldingDaysOverall=$(printf "%.1f" "$averageHoldingDaysOverall")
Out "Avg Holding Busi.Days Overall=$averageHoldingDaysOverall Days" $OUT_SIMULATE_FILE
winOverAll=$(printf "%.0f" "$winOverAll")
Out "Win Overall=$winOverAll€" $OUT_SIMULATE_FILE

if [ "$sellAmountOverAll" = 0 ]; then
    prozWinOverAll=0
else
    prozWinOverAll=$(echo "$winOverAll $sellAmountOverAll" | awk '{print (($1 / $2 * 100))}')
    prozWinOverAll=$(printf "%.1f" "$prozWinOverAll")
fi
Out "Win Percentage (100 Busi.Days)=$prozWinOverAll%" $OUT_SIMULATE_FILE
prozWinOverAll1Year=$(echo "$prozWinOverAll 2.5" | awk '{print ($1 * $2)}') # 100 Kurse -> 250 Arbeitstage
Out "Estimated Win Percentage 1 Year (250 Busi.Days)=$prozWinOverAll1Year%" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE

# Workflow  
{       
    echo "<br># Workflow<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=\"_blank\">Github Action</a><br>"
    echo "<br># Result<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result_schedule.html\" target=\"_blank\">Result Schedule SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result.html\" target=\"_blank\">Result&nbsp;SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate.html\" target=\"_blank\">Simulation</a><br>"
    echo "<br># Informer<br><a href=\"https://nutzer.comdirect.de/inf/musterdepot/pmd/meineuebersicht.html?name=Max\" target=\"_blank\">Comdirect Informer</a><br>"
    echo "<br>"
} >> $OUT_SIMULATE_FILE
Out "Good Luck! $creationDate" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
echo "</body></html>" >> $OUT_SIMULATE_FILE
