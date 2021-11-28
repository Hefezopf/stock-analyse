#!/usr/bin/env bash

# This script simulates a given stock quote.
# Call: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# 7. Parameter: KEEP_IF_UNDER_PERCENTAGE: Keep if position is under this value: like 1 means 1% or more gain -> not sell.
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI ALV' 2000 25 91 1.1 5 1
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2000 25 91 1.1 5 1
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2500 10 96 1.01 5 1

# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. ./script/functions.sh

# Parameter
symbolsParam=$1
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StochSellLevelParam=$4
incrementPerTradeParam=$5
sellIfOverPercentageParam=$6
keepIfUnderPercentageParam=$7

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

OUT_SIMULATE_FILE="out/_simulate.html"
TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
QUOTE_MAX_VALUE=999999
RSI_MAX_VALUE=100

#rm -rf "$OUT_SIMULATE_FILE"
sellAmountOverAll=0
sellOnLastDayAmountOverAll=0
export winOverall=0
export _outputText=""

 # shellcheck disable=SC2140
echo "<!DOCTYPE html><html lang="en"><head><meta charset="utf-8" /><link rel="shortcut icon" type="image/ico" href="favicon.ico" /><title>Simulate</title></head><body>" >> $OUT_SIMULATE_FILE

Out "" $OUT_SIMULATE_FILE
Out "# Simulate BuyRSILowMACDNegativ SellHighStoch" $OUT_SIMULATE_FILE
Out "#############################################" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
Out "Symbols($countSymbols):$symbolsParam" $OUT_SIMULATE_FILE
Out "Amount Per Trade:$amountPerTradeParam€" $OUT_SIMULATE_FILE
Out "RSI Buy Level:$RSIBuyLevelParam" $OUT_SIMULATE_FILE
Out "Stoch Sell Level:$StochSellLevelParam" $OUT_SIMULATE_FILE
Out "Increment Per Trade:$incrementPerTradeParam" $OUT_SIMULATE_FILE
Out "Sell Over Percentage:$sellIfOverPercentageParam" $OUT_SIMULATE_FILE
Out "Keep Under Percentage:$keepIfUnderPercentageParam" $OUT_SIMULATE_FILE

# Simulate stock for each symbol
for symbol in $symbolsParam
do
    lastLowestQuoteAt=$QUOTE_MAX_VALUE
    amountOfTrades=0
    buyingDay=0
    wallet=0
    simulationWin=0
    piecesHold=0
    amountPerTrade=$amountPerTradeParam
    symbolName=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
    Out "" $OUT_SIMULATE_FILE

    CreateCmdHyperlink "Simulation" "simulate/out"
    echo "<a href=\"http://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/""$symbol"".html $symbolName\" target=\"_blank\">$_outputText</a><br>" >> $OUT_SIMULATE_FILE  
    HISTORY_FILE=history/"$symbol".txt
    historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
    historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)
    historyRSIs=$(head -n6 "$HISTORY_FILE" | tail -1)
    historyMACDs=$(head -n8 "$HISTORY_FILE" | tail -1)

    RSIindex=1
    # shellcheck disable=SC2001
    for valueRSI in $(echo "$historyRSIs" | sed "s/,/ /g")
    do
        # Buy
        MACDAt="$(echo "$historyMACDs" | cut -f "$RSIindex" -d ',')"
        if [ "$RSIindex" -gt 2 ]; then
            lastMACDAt="$(echo "$historyMACDs" | cut -f "$((RSIindex - 1))" -d ',')"
            beforeLastMACDAt="$(echo "$historyMACDs" | cut -f "$((RSIindex - 2))" -d ',')"
        fi
        isMACDNegativ=$(echo "$MACDAt" | awk '{print substr ($0, 0, 1)}')
        isLastMACDNegativ=$(echo "$lastMACDAt" | awk '{print substr ($0, 0, 1)}')
        isbeforeLastMACDNegativ=$(echo "$beforeLastMACDAt" | awk '{print substr ($0, 0, 1)}')
        # RSI low, last 3 MACD values negativ
        if [ "$valueRSI" -lt "$RSIBuyLevelParam" ] && [ "$isMACDNegativ" = '-' ] && [ "$isLastMACDNegativ" = '-' ] && [ "$isbeforeLastMACDNegativ" = '-' ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 

            # Buy on new lows
            newLower=$(echo "$quoteAt" "$lastLowestQuoteAt" | awk '{if ($1 < $2) print "true"; else print "false"}')
            if [ "$newLower" = true ]; then
                piecesPerTrade=$(echo "$amountPerTrade $quoteAt" | awk '{print ($1 / $2)}')
                amountPerTrade=$(echo "$amountPerTrade $incrementPerTradeParam" | awk '{print ($1 * $2)}')
                piecesPerTrade=${piecesPerTrade%.*}
                if [ "$piecesPerTrade" -eq 0 ]; then
                    piecesPerTrade=1
                fi
                # 10 Euro Fees each Buy trade
                amount=$(echo "$quoteAt $piecesPerTrade 10" | awk '{print ($1 * $2) + $3}')
                amount=$(printf "%.0f" "$amount")
                piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
                wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
                wallet=$(printf "%.0f" "$wallet")
                quoteAt=$(printf "%.2f" "$quoteAt")
                Out "Buy\tPos:$RSIindex\t""$piecesPerTrade""Pc\tQuote:$quoteAt€\tAmount:$amount€\tRSI:$valueRSI\tPieces:$piecesHold\tWallet:$wallet€" $OUT_SIMULATE_FILE
                buyingDay=$((buyingDay + RSIindex))
                amountOfTrades=$((amountOfTrades + 1)) 

                lastLowestQuoteAt="$quoteAt" 

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
                ARRAY_BUY[RSIindex]=$amount
             
            fi     
            RSIBuyLevelParam=$RSI_MAX_VALUE              
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
            isIntermediateProzWinGT=$(echo "$intermediateProzWin" | awk '{print substr ($0, 0, 1)}')    
            if [ "$isIntermediateProzWinGT" = '-' ]; then 
                isIntermediateProzWinGT=0
            fi
            # Sell at 5 Percent or, if over Stoch Level
            if [ "$isIntermediateProzWinGT" -gt "$sellIfOverPercentageParam" ] || [ "$stochAt" -gt "$StochSellLevelParam" ]; then
                isIntermediateProzWinNegativ=$(echo "$intermediateProzWin" | awk '{print substr ($0, 0, 1)}')
                # NOT Sell, if would be a negative trade
                if [ ! "$isIntermediateProzWinNegativ" = '-' ]; then
                    # ONLY Sell, if percent is over 1%
                    if [ "$isIntermediateProzWinGT" -gt "$keepIfUnderPercentageParam" ]; then                   
                        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
                        wallet=$(printf "%.0f" "$wallet")
                        sellAmountOverAll=$(echo "$amount $sellAmountOverAll" | awk '{print ($1 + $2)}')
                        Out "Sell\tPos:$RSIindex\t""$piecesHold""pc\tQuote:$quoteAt€\tAmount:$amount€\tStoch:$stochAt" $OUT_SIMULATE_FILE
                        anualPercentWin=$(echo "360 $averageHoldingDays" | awk '{print ($1 / $2)}')
                        anualPercentWin=$(echo "$anualPercentWin $intermediateProzWin" | awk '{print ($1 * $2)}')
                        anualPercentWin=$(printf "%.0f" "$anualPercentWin")
                        Out "Intermediate Win=$wallet€ Perc=$intermediateProzWin% AnualPerc=$anualPercentWin% Avg Holding Days=$averageHoldingDays Days" $OUT_SIMULATE_FILE
                        simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}')
                        piecesHold=0
                        wallet=0
                        amountPerTrade="$amountPerTradeParam"
                        amountOfTrades=0
                        buyingDay=0
                        lastLowestQuoteAt=$QUOTE_MAX_VALUE
                        RSIBuyLevelParam=$3

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

                    fi
                fi
            fi
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
        Out "Keep\tPos:100\t""$piecesHold""pc\tQuote:$quoteAt€\tAmount=$amount€" $OUT_SIMULATE_FILE
        sellOnLastDayAmountOverAll=$(echo "$sellOnLastDayAmountOverAll $amount" | awk '{print ($1 + $2)}')
        lastLowestQuoteAt=$QUOTE_MAX_VALUE 
        RSIBuyLevelParam=$3
    fi

    isSimulationWinNull=$(echo "$simulationWin" | awk '{print substr ($0, 0, 1)}')
    if [ ! "$isSimulationWinNull" = '0' ]; then
        Out "--------------------------" $OUT_SIMULATE_FILE
        Out "Sell Amount Overall=$sellAmountOverAll€" $OUT_SIMULATE_FILE
        simulationWin=$(printf "%.0f" "$simulationWin")
        Out "Simulation Win=$simulationWin€" $OUT_SIMULATE_FILE
        winOverAll=$(echo "$winOverAll $simulationWin" | awk '{print ($1 + $2)}')
        prozSimulationWinOverAll=$(echo "$simulationWin $sellAmountOverAll" | awk '{print (($1 / $2 * 100))}')
        prozSimulationWinOverAll=$(printf "%.1f" "$prozSimulationWinOverAll")
    fi 

    cp out/$symbol.html simulate/out/$symbol.html
    sed -i '/labels: /c\labels: ['14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99'' simulate/out/$symbol.html
done

# for i in "${!ARRAY_BUY[@]}"; do
#   Out "$i Buy:${ARRAY_BUY[i]}" $OUT_SIMULATE_FILE
# done

# Out "" $OUT_SIMULATE_FILE

# for j in "${!ARRAY_SELL[@]}"; do
#   Out "$j Sell:-${ARRAY_SELL[j]}" $OUT_SIMULATE_FILE
# done

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

# Out "" $OUT_SIMULATE_FILE

# Output Diff Array
# for i in "${!ARRAY_DIFF[@]}"; do
#   Out "$i Diff:${ARRAY_DIFF[i]}" $OUT_SIMULATE_FILE
# done

Out "" $OUT_SIMULATE_FILE

liquidity=0
# Output Liquidity
for i in "${!ARRAY_DIFF[@]}"; do
    valueDiffArray="${ARRAY_DIFF[i]}"
    liquidity=$(echo "$liquidity $valueDiffArray" | awk '{print ($1 - $2)}')
    Out "$i Liquidity:$liquidity" $OUT_SIMULATE_FILE
done

isLiquidityNegativ=$(echo "$liquidity" | awk '{print substr ($0, 0, 1)}')
if [ "$isLiquidityNegativ" = '-' ]; then
    Out "Currently invested (in Stocks):$liquidity" $OUT_SIMULATE_FILE                
else
    Out "Currently Liquidity Cash to spend:$liquidity" $OUT_SIMULATE_FILE
fi

Out "" $OUT_SIMULATE_FILE
Out "# Parameter" $OUT_SIMULATE_FILE
Out "Amount Per Trade:$amountPerTradeParam€" $OUT_SIMULATE_FILE
Out "RSI Buy Level:$RSIBuyLevelParam" $OUT_SIMULATE_FILE
Out "Stoch Sell Level:$StochSellLevelParam" $OUT_SIMULATE_FILE
Out "Increment Per Trade:$incrementPerTradeParam" $OUT_SIMULATE_FILE
Out "Sell Over Percentage:$sellIfOverPercentageParam" $OUT_SIMULATE_FILE
Out "Keep Under Percentage:$keepIfUnderPercentageParam" $OUT_SIMULATE_FILE
Out "==========================" $OUT_SIMULATE_FILE
sellAmountOverAll=$(printf "%.0f" "$sellAmountOverAll")
Out "Sell Amount Overall=$sellAmountOverAll€" $OUT_SIMULATE_FILE
sellOnLastDayAmountOverAll=$(printf "%.0f" "$sellOnLastDayAmountOverAll")
Out "Still in Portfolio After Last Day=$sellOnLastDayAmountOverAll€" $OUT_SIMULATE_FILE
winOverAll=$(printf "%.0f" "$winOverAll")
Out "Win Overall=$winOverAll€" $OUT_SIMULATE_FILE
prozWinOverAll=$(echo "$winOverAll $sellAmountOverAll" | awk '{print (($1 / $2 * 100))}')
prozWinOverAll=$(printf "%.1f" "$prozWinOverAll")
Out "Perc=$prozWinOverAll%" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE

creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
if [ "$(uname)" = 'Linux' ]; then
    creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # +2h
fi

Out "Good Luck! Donate? $creationDate" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
echo "</body></html>" >> $OUT_SIMULATE_FILE
