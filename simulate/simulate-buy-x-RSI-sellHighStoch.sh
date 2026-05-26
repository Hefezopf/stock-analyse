#!/bin/bash

# This script simulates a given stock quote.
# Call: simulate/simulate-buy-x-RSI-sellHighStoch.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE SELL_IF_OVER_PERCENTAGE KEEP_IF_UNDER_PERCENTAGE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 3000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 50
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# NOT USED!!! -----# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# 7. Parameter: KEEP_IF_UNDER_PERCENTAGE: Keep if position is under this value: like 1 means 1% or more gain -> not sell.
# 8. Parameter: xxx
# 9. Parameter: xxx
# Call example: simulate/simulate-buy-x-RSI-sellHighStoch.sh 'BEI' 3000 25 50 1.1 99 2
# Call example: simulate/simulate-buy-x-RSI-sellHighStoch.sh 'BEI HLE GZF TNE5' 3000 25 50 1.1 99 1
# Call example: simulate/simulate-buy-x-RSI-sellHighStoch.sh 'BEI HLE GZF TNE5' 3000 25 50 1.01 99 1

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

START_TIME_MEASUREMENT=$(date +%s);

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
amountPerTradeParam=$2
RSIBuyLevelParam=$3
stochSellLevelParam=$4
incrementPerTradeParam=$5
sellIfOverPercentageParam=$6 # NOT USED!!!
keepIfUnderPercentageParam=$7

recommendedAlarmPattern="+7R"
#recommendedAlarmPattern="7S+7R"

# Settings for currency formating like ',' or '.' with 'printf'
#export LC_ALL=en_US.UTF-8
export LC_ALL=C.UTF-8

cp out/_result.js simulate/out

OUT_SIMULATE_FILE="simulate/out/_simulate.html"
ARRAY_BUY_POS_SIM=()

function ParameterOut()
{
    #Out "!!! DATA_DIR:$DATA_DIR" $OUT_SIMULATE_FILE
    Out "Amount Per Trade:$amountPerTradeParam€" $OUT_SIMULATE_FILE
    Out "RSI Buy Level:$RSIBuyLevelParam" $OUT_SIMULATE_FILE
    Out "Stoch Sell Level:$stochSellLevelParam" $OUT_SIMULATE_FILE
    Out "Increment Per Trade:$incrementPerTradeParam" $OUT_SIMULATE_FILE
    Out "Sell Over Percentage (NOT USED!!!):$sellIfOverPercentageParam" $OUT_SIMULATE_FILE
    Out "Keep Under Percentage:$keepIfUnderPercentageParam" $OUT_SIMULATE_FILE
    Out "Alarm Pattern:$recommendedAlarmPattern" $OUT_SIMULATE_FILE    
}

mkdir -p "$TEMP_DIR/config"
cp "$TICKER_NAME_ID_FILE" "$TEMP_DIR/config"

mkdir -p simulate/out
sellAmountOverAll=0
sellOnLastDayAmountOverAll=0
sellOnLastDayLostAmountOverAll=0
averageHoldingDaysOverallDays=0
averageHoldingDaysOverallSymbols=0
export alarmAbbrevTemplate # from functions.sh
export winOverall=0
export _outputText=""
export TX_FEE

# shellcheck disable=SC2140
echo "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8' /><link rel='icon' type='image/x-icon' href='favicon.ico' /><script type='text/javascript' src='_result.js' async></script><title>Simulate</title>
<style type='text/css'>
/* iPhone 3 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 1) {
    body > div {
        font-size: xx-large;
    }
}
        
/* iPhone 4 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 5 */
@media only screen and (min-device-width: 320px) and (max-device-height: 568px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 6, 6s, 7, 8 */
@media only screen and (min-device-width: 375px) and (max-device-height: 667px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone 6+, 6s+, 7+, 8+ */
@media only screen and (min-device-width: 414px) and (max-device-height: 736px) and (-webkit-device-pixel-ratio: 3) { 
    body > div {
        font-size: xx-large;
    }
}

/* iPhone X, XS, 11 Pro, 12 Mini */
@media only screen and (min-device-width: 375px) and (max-device-height: 812px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro, 14 Mini (Meines 2023) */
@media only screen and (min-device-width: 390px) and (max-device-height: 844px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        width: 25em;
        font-size: xx-large;
    }
}

/* iPhone XR, 11 */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone XS Max, 11 Pro Max */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro Max */
@media only screen and (min-device-width: 428px) and (max-device-height: 926px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 16 (Meines 09/2024) */
@media only screen and (min-device-width: 393px) and (max-device-height: 852px) and (-webkit-device-pixel-ratio: 3) {
    body {
        font-size: xx-large;
        /* background: red; */
    }
}

/* Safari */
@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>" >> $OUT_SIMULATE_FILE
echo "</head><body>" >> $OUT_SIMULATE_FILE

Out "" $OUT_SIMULATE_FILE
Out "# SA Simulate" $OUT_SIMULATE_FILE
Out "############" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
Out "Symbols($countSymbols):$symbolsParam" $OUT_SIMULATE_FILE

ParameterOut

echo "<br><button id='buttonGoToEnd' style='font-size:large; height: 60px; width: 110px;' type='button' onclick='function doGoToEnd(){var scrollingElement = (document.scrollingElement || document.body);scrollingElement.scrollTop = scrollingElement.scrollHeight;};doGoToEnd()'>To End</button>" >> $OUT_SIMULATE_FILE
echo "&nbsp;<a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate.html\" target=\"_blank\">Simulation</a><br>" >> $OUT_SIMULATE_FILE

# Simulate stocks for each symbol
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

    if [ "${symbol::1}" = '*' ]; then
        symbol="${symbol:1:7}"
    fi

    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE_MEM")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
            
    Out "" $OUT_SIMULATE_FILE

    CreateCmdHyperlink "Simulation" "simulate/out" "$symbol" #"$symbolName"

    # Market Cap
    marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    lowMarketCapLinkBackgroundColor="white"
    if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
        lowMarketCapLinkBackgroundColor="$MOCCASIN" #"rgba(251, 225, 173)"
    fi
    WriteComdirectUrlAndStoreFileList "$OUT_SIMULATE_FILE" "$symbol" "$symbolName" "$BLACK" "" "" "$lowMarketCapLinkBackgroundColor" "/simulate" "$ID_NOTATION"

    HISTORY_FILE=history/"$symbol".txt
    historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
    historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)

    quoteIndex=0
    for quoteAt in ${historyQuotes//,/ }
    do
        quoteIndex=$((quoteIndex+1))
        if [ "$quoteIndex" -lt 26 ]; then
            #echo "-------skip first 26: $quoteIndex $quoteAt"
            continue
        fi

        ARRAY_TX_BUY_PRICE[quoteIndex]="{}"
        ARRAY_TX_SELL_PRICE[quoteIndex]="{}"
        isHoldPiecesAndNewLow=false

        posInAlarm=$((quoteIndex-13))
        # shellcheck disable=SC2002
        lastAlarm=$(cat alarm/"$symbol".txt | cut -f "$posInAlarm"-"$posInAlarm" -d ',')  
        #echo "==========quoteIndex: lastAlarm: $quoteIndex: $lastAlarm"

        isNewLow=false
        isNewLowPattern="N"
        if [ "${lastAlarm#*"$isNewLowPattern"}" != "$lastAlarm" ]; then # isNewLowPattern
            isNewLow=true
        fi

        if [ "${#ARRAY_BUY[@]}" -gt 0 ]; then
            isBuyArrayFilled=true
        else
            isBuyArrayFilled=false
        fi

        # Allways buy, if already hold pieces and new low
        if [ "$isBuyArrayFilled" = true ] && [ "$piecesHold" -gt 0 ] && [ "$isNewLow" = true ]; then
            isHoldPiecesAndNewLow=true
        else
            isHoldPiecesAndNewLow=false
        fi

        # Buy
        vorzeichen="${lastAlarm: -2 : -1}"
        if [ "$vorzeichen" = '+' ]; then # Check if lastAlarm buying values
            if [ "${lastAlarm#*"$recommendedAlarmPattern"}" != "$lastAlarm" ] || [ "$isHoldPiecesAndNewLow" = true ]; then # Check if lastAlarm buying values
                #echo "----------------------> Recommended $symbol $symbolName: $recommendedAlarmPattern found in $lastAlarm"
                lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE_MEM")
                symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
                ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
                linkBackgroundColor="$WHITE" # default
                # Market Cap
                marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
                asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
                if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then # lowMarketCap 
                    linkBackgroundColor="$MOCCASIN" #"rgba(251, 225, 173)"
                fi            
                WriteComdirectUrlAndStoreFileList "$OUT_SIMULATE_FILE" "$symbol" "$symbolName" "$BLACK" "" "" "$linkBackgroundColor" "" "$ID_NOTATION"

                marketCapFromFile=10000 # Make CalculateMarketCapRSILevel() allways true in the subsequent caluculations
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
                amount=$((amount - TX_FEE))
                
                piecesHold=$((piecesHold+piecesPerTrade))
                wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
                wallet=$(printf "%.0f" "$wallet")
                quoteAt=$(printf "%.2f" "$quoteAt")
                Out "Buy\tPos:$quoteIndex\t""$piecesPerTrade""Pc\tQuote:$quoteAt€\tAmount:$amount€\tAlarm:$lastAlarm\tPieces:$piecesHold\tWallet:$wallet€" $OUT_SIMULATE_FILE
                buyingDay=$((buyingDay + quoteIndex))
                amountOfTrades=$((amountOfTrades + 1))

                # Calculate ARRAY_BUY
                for i in "${!ARRAY_BUY[@]}"; do
                    if [ "$i" -eq "$quoteIndex" ]; then
                        valueArray="${ARRAY_BUY[i]}"
                        if [ "${ARRAY_BUY[i]}" = '' ]; then
                            Out "SHOUD NOT HAPPEN" $OUT_SIMULATE_FILE
                            valueArray=0
                        fi
                        amount=$(echo "$valueArray $amount" | awk '{print ($1 + $2)}')
                    fi
                done

                if [ "$quoteIndex" -eq 100 ]; then
                    ARRAY_BUY_POS_SIM+=("$symbol")
                fi

                ARRAY_BUY[quoteIndex]=$amount
                ARRAY_TX_INDEX[quoteIndex]="$wallet€"                     
                ARRAY_TX_BUY_PRICE[quoteIndex]="{x:1,y:$quoteAt,r:10}"
            fi
        fi

        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$quoteIndex" -d ',')" 
        quoteAt="$(echo "$historyQuotes" | cut -f "$quoteIndex" -d ',')" 
        if [ "$piecesHold" -gt 0 ]; then
            # 20 Euro Fees each Sell trade
            amount=$(echo "$quoteAt $piecesHold 20" | awk '{print ($1 * $2) - $3}')
            amount=$(printf "%.0f" "$amount")
            quoteAt=$(printf "%.2f" "$quoteAt")
            averageBuyingDay=$(echo "$buyingDay $amountOfTrades" | awk '{print ($1 / $2)}')
            averageHoldingDays=$(echo "$quoteIndex $averageBuyingDay" | awk '{print ($1 - $2)}')
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
            if [ "$stochAt" -gt "$stochSellLevelParam" ]; then
            #if [ "$intermediateProzWinFirstDigit" -gt "$sellIfOverPercentageParam" ] || [ "$stochAt" -gt "$stochSellLevelParam" ]; then
                isIntermediateProzWinNegativ=${intermediateProzWin:0:1}
                # NOT Sell, if tx would be a negative trade
                if [ ! "$isIntermediateProzWinNegativ" = '-' ]; then
                    # ONLY Sell, if gain percentage is over KEEP_IF_UNDER_PERCENTAGE (1%)
                    if [ "$intermediateProzWinFirstDigit" -ge "$keepIfUnderPercentageParam" ]; then
                        wallet=$((amount-wallet))
                        wallet=$(printf "%.0f" "$wallet")
                        sellAmountOverAll=$((amount+sellAmountOverAll))
                        
                        Out "Sell\tPos:$quoteIndex\t""$piecesHold""pc\tQuote:$quoteAt€\tAmount:$amount€\tStoch:$stochAt" $OUT_SIMULATE_FILE
                        
                        #anualPercentWin=$(echo "360 $averageHoldingDays" | awk '{print ($1 / $2)}')
                        anualPercentWin=$(echo "250 $averageHoldingDays" | awk '{print ($1 / $2)}') # -> 250 Arbeitstage
                        anualPercentWin=$(echo "$anualPercentWin $intermediateProzWin" | awk '{print ($1 * $2)}')
                        anualPercentWin=$(printf "%.0f" "$anualPercentWin")
                        Out "Intermediate Win=$wallet€ Perc=$intermediateProzWin% Estimated AnualPerc=$anualPercentWin% Avg. Holding Busi.Days=$averageHoldingDays Days" $OUT_SIMULATE_FILE

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
                        # Reset MarketCap
                        marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)

                        # Calculate ARRAY_SELL
                        for i in "${!ARRAY_SELL[@]}"; do
                            if [ "$i" -eq "$quoteIndex" ]; then
                                valueArray="${ARRAY_SELL[i]}"
                                if [ "${ARRAY_SELL[i]}" = '' ]; then
                                    valueArray=0
                                fi
                                amount=$(echo "$valueArray $amount" | awk '{print ($1 + $2)}')
                            fi
                        done
                        ARRAY_SELL[quoteIndex]=$amount
                        ARRAY_TX_INDEX[quoteIndex]="+$wallet€+$intermediateProzWin%"
                        ARRAY_TX_SELL_PRICE[quoteIndex]="{x:1,y:$quoteAt,r:10}"
                        wallet=0
                    fi
                fi
            fi
        fi
        #RSIindex=$((RSIindex + 1))
    done

    # Sell all on the last day, to get gid of all stocks for simulation
    if [ "$piecesHold" -gt 0 ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f 100 -d ',')" 
        Out "Keep on the last day!!" $OUT_SIMULATE_FILE
        # 1 Euro Fees each Last Day Sell trade
        amount=$(echo "$quoteAt $piecesHold 1" | awk '{print ($1 * $2) - $3}')
        amount=$(printf "%.0f" "$amount")
        quoteAt=$(printf "%.2f" "$quoteAt")
        percentageLost=$(echo "$wallet $amount" | awk '{print (100-(100 / $1 * $2 ))*(-1)}')
        percentageLost=$(printf "%.1f" "$percentageLost")
        amountLostOnLastDay=$((amount-wallet))
        Out "Keep\tPos:100\t""$piecesHold""pc\tQuote:$quoteAt€\tCurrent Value=$amount€\tLost=$amountLostOnLastDay€\tPerc=$percentageLost%" $OUT_SIMULATE_FILE
        sellOnLastDayAmountOverAll=$(echo "$sellOnLastDayAmountOverAll $amount" | awk '{print ($1 + $2)}')
        sellOnLastDayLostAmountOverAll=$(echo "$sellOnLastDayLostAmountOverAll $amountLostOnLastDay" | awk '{print ($1 + $2)}')
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

    # Search and Replace
    #lineNumer=$(grep -wn "X_AXIS_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html | cut -f 1 -d ':') # | cut -f 1 -d ':'
    lineNumer=$(grep -wn "X_AXIS_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html) 
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#echo "-----lineNumer:$lineNumer"    
    lineNumer=$((lineNumer+1)) # 81
    # Write/Replace X-Axis
    xAxis="$alarmAbbrevTemplate"",'100'"
#echo "-----xAxis:$xAxis"    
    for i in "${!ARRAY_TX_INDEX[@]}"; do
        # Buy may replace some Sell-XXX values -> looks strange: 'SELL-9BUY
        #xAxis=$(echo "$xAxis" | sed "s/'$i'/'${ARRAY_TX_INDEX[i]}'/g")
        xAxis="${xAxis//"'$i'"/"'${ARRAY_TX_INDEX[i]}'"}"
    done
#echo "####xAxis:$xAxis"     
    labelsTemplate="labels:[$xAxis"
    sed -i """$lineNumer""s/.*/$labelsTemplate/" simulate/out/"$symbol".html

    # Search and Replace
    #lineNumer=$(grep -wn "BUY_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html | cut -f 1 -d ':') # | cut -f 1 -d ':'
    lineNumer=$(grep -wn "BUY_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#    echo "-----lineNumer:$lineNumer" 
    lineNumer=$((lineNumer+1)) # 182
    # Write/Replace "buy"
    buySequenceReplaced="{},{},{},{},{},{},{},{},{},{},{},{},"
    for i in "${!ARRAY_TX_BUY_PRICE[@]}"; do
        if [ "$i" -ge '26' ]; then
            buySequenceReplaced="$buySequenceReplaced${ARRAY_TX_BUY_PRICE[i]},"
        fi
    done
    sed -i """$lineNumer""s/.*/$buySequenceReplaced/" simulate/out/"$symbol".html    

    # Search and Replace
    #lineNumer=$(grep -wn "SELL_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html | cut -f 1 -d ':') # | cut -f 1 -d ':'
    lineNumer=$(grep -wn "SELL_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#    echo "-----lineNumer:$lineNumer" 
    lineNumer=$((lineNumer+1)) # 189
    # Write/Replace "sell"
    sellSequenceReplaced="{},{},{},{},{},{},{},{},{},{},{},{},"
    for i in "${!ARRAY_TX_SELL_PRICE[@]}"; do
        if [ "$i" -ge '26' ]; then
            sellSequenceReplaced="$sellSequenceReplaced${ARRAY_TX_SELL_PRICE[i]},"
        fi
    done
    sed -i """$lineNumer""s/.*/$sellSequenceReplaced/" simulate/out/"$symbol".html

    if [ "$piecesHold" -gt 0 ]; then
        currentAvg=$(echo "$wallet $piecesHold" | awk '{print ($1 / $2)}')
    else
        currentAvg="$quoteAt"
    fi

    # Search and Replace
    lineNumer=$(grep -wn "BUYING_LAST_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
  #  echo "-----lineNumer:$lineNumer" 
    lineNumer=$((lineNumer+1)) # 218
    dataTemplate="data:[X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,]},"
    buyingAvgSequenceReplaced=$(echo -n "$dataTemplate" | sed "s/X/${currentAvg}/g")
    sed -i """$lineNumer""s/.*/$buyingAvgSequenceReplaced/" simulate/out/"$symbol".html

    # Search and Replace
    lineNumer=$(grep -wn "5_PERCENT_OVER_UNDERNEATH_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#  echo "-----lineNumer:$lineNumer" 
    # Draw 5% over buying/last quote
    percentOverBuyingAvg=$(echo "$currentAvg 1.05" | awk '{print $1 * $2}')
    percentOverBuyingAvgSequenceReplaced=$(echo -n "$dataTemplate" | sed "s/X/${percentOverBuyingAvg}/g")
    lineNumer=$((lineNumer+1)) # 224
    sed -i """$lineNumer""s/.*/$percentOverBuyingAvgSequenceReplaced/" simulate/out/"$symbol".html

    # Search and Replace
    lineNumer=$(grep -wn "STOCH_HIGH_PARAM_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#   echo "-----lineNumer:$lineNumer" 
    borderColor="borderColor: window.chartColors.red,"
    sed -i """$lineNumer""s/.*/$borderColor/" simulate/out/"$symbol".html
    dataStochTemplate="data:[X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X"
    stochSellingSequenceReplaced=$(echo -n "$dataStochTemplate" | sed "s/X/${stochSellLevelParam}/g")
    lineNumer=$((lineNumer+1)) # 286
    sed -i """$lineNumer""s/.*/$stochSellingSequenceReplaced/" simulate/out/"$symbol".html

    # Search and Replace
    lineNumer=$(grep -wn "RSI_LOW_PARAM_TO_BE_REPLACED" out/"$symbol".html)
    lineNumer=${lineNumer%*":"*}
    lineNumer=${lineNumer%*":"*}
#    echo "-----lineNumer:$lineNumer" 
    borderColor="borderColor: window.chartColors.green,"
    sed -i """$lineNumer""s/.*/$borderColor/" simulate/out/"$symbol".html
    dataRSIBuyTemplate="data:[X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X"
    RSIBuySequenceReplaced=$(echo -n "$dataRSIBuyTemplate" | sed "s/X/${RSIBuyLevelParam}/g")
    lineNumer=$((lineNumer+1)) # 368
    sed -i """$lineNumer""s/.*/$RSIBuySequenceReplaced/" simulate/out/"$symbol".html

    # Search and Replace
    # path to country flag
    sed -i 's/image\/flags/..\/image\/flags/g' simulate/out/"$symbol".html

    # Search and Replace
    lineNumer=$(grep -wn "Good Luck!" out/"$symbol".html)
    lineNumer=${lineNumer%*"<"*}
    lineNumer=${lineNumer%*"<"*}
    lineNumer=${lineNumer%*"<"*}
    lineNumer=${lineNumer%*"<"*}
    lineNumer=${lineNumer%*"<"*}
    lineNumer=${lineNumer%*":"*} # 568

    GetCreationDate
    # shellcheck disable=SC2154
    GOOD_LUCK="<br>Good Luck! $creationDate"
    sed -i """$lineNumer""s/.*/$GOOD_LUCK/" simulate/out/"$symbol".html
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

echo "<script>var linkMap = new Map();</script>" >> $OUT_SIMULATE_FILE

echo "<br><button id='buttonOpenAllInTab' style='font-size:large; height: 60px; width: 110px;' type='button' onclick='javascript:doOpenAllInTab()'>Open All</button><br><br>" >> $OUT_SIMULATE_FILE
for symbol in "${ARRAY_BUY_POS_SIM[@]}"
do
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE_MEM")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
    ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
    marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
    asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
    lowMarketCapLinkBackgroundColor="white"
    if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
        lowMarketCapLinkBackgroundColor="$MOCCASIN" #"rgba(251, 225, 173)"
    fi

    export ID_NOTATION_STORE_FOR_NEXT_TIME=""
    WriteComdirectUrlAndStoreFileList "$OUT_SIMULATE_FILE" "$symbol" "$symbolName" "$BLACK" "" "" "$lowMarketCapLinkBackgroundColor" "/simulate" "$ID_NOTATION"

    echo "$symbol $symbolName"
    # shellcheck disable=SC2027,SC2086
    echo "<script>linkMap.set(\""$symbol"\", \"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/""$symbol"".html\");</script>" >> $OUT_SIMULATE_FILE
done

Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
ParameterOut
Out "==========================" $OUT_SIMULATE_FILE
sellAmountOverAll=$(printf "%.0f" "$sellAmountOverAll")
Out "Sell Amount overall (Sales Volume)=$sellAmountOverAll€" $OUT_SIMULATE_FILE
sellOnLastDayAmountOverAll=$(printf "%.0f" "$sellOnLastDayAmountOverAll")
Out "Now still in Portfolio=$sellOnLastDayAmountOverAll€" $OUT_SIMULATE_FILE
Out "Now potential Lost, if sell all=$sellOnLastDayLostAmountOverAll€" $OUT_SIMULATE_FILE
averageHoldingDaysOverall=$(printf "%.1f" "$averageHoldingDaysOverall")
Out "Avg. holding Busi.Days overall=$averageHoldingDaysOverall Days" $OUT_SIMULATE_FILE
winOverAll=$(printf "%.0f" "$winOverAll")
Out "Win overall (74 Busi.Days)=$winOverAll€" $OUT_SIMULATE_FILE

if [ "$sellAmountOverAll" = 0 ]; then
    prozWinOverAll=0
else
    prozWinOverAll=$(echo "$winOverAll $sellAmountOverAll" | awk '{print (($1 / ($2-$1) * 100))}')
    prozWinOverAll=$(printf "%.1f" "$prozWinOverAll")
fi

Out "Win Percentage (74 Busi.Days)=$prozWinOverAll%" $OUT_SIMULATE_FILE
prozWinOverAll1Year=$(echo "$prozWinOverAll 3.8" | awk '{print ($1 * $2)}') # Factor 3.8: 74 Kurse -> 250 Arbeitstage
winOverAll1Year=$(echo "$winOverAll 3.8" | awk '{print ($1 * $2)}') # 74 Kurse -> 250 Arbeitstage
Out "Annually Win (250 Busi.Days)=$winOverAll1Year€" $OUT_SIMULATE_FILE
Out "Annually Win Percentage (250 Busi.Days)=$prozWinOverAll1Year%" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE

# Workflow  
{       
    echo "<br># Workflow<br><a href=\"https://github.com/Hefezopf/stock-analyse/actions\" target=\"_blank\">Github Action</a><br>"
    echo "<br># Result<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result_schedule.html\" target=\"_blank\">Result Schedule SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/_result.html\" target=\"_blank\">Result&nbsp;SA</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate.html\" target=\"_blank\">Simulation</a>"
    echo "<br><a href=\"https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/$SIM_LAST_ALARMS_HTML_FILE\" target=\"_blank\">Simulation Last Alarms</a><br>"
    echo "<br># Informer<br><a href=\"https://nutzer.comdirect.de/inf/musterdepot/pmd/meineuebersicht.html?name=Max\" target=\"_blank\">Comdirect Informer</a><br>"
    echo "<br>"
} >> "$OUT_SIMULATE_FILE"
Out "Good Luck! $creationDate" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
echo "</body></html>" >> $OUT_SIMULATE_FILE

rm -rf "$TEMP_DIR"/config

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
