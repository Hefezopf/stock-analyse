#!/bin/sh

# This script simulates a given stock quote.
# Call: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI ALV' 2000 25 91 1.1 5
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2000 25 91 1.1 5
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI HLE GZF TNE5' 2500 10 96 1.01 5

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

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

OUT_SIMULATE_FILE="out/_simulate.html"
TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
QUOTE_MAX_VALUE=999999

#rm -rf "$OUT_SIMULATE_FILE"
sellAmountOverAll=0
export winOverall=0
walletOverAll=0

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
Out "Sell if over Percentage:$sellIfOverPercentageParam" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE

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

    CreateCmdHyperlink "Simulation"
    echo "<a href=\"http://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/""$symbol"".html\" target=\"_blank\">$_outputText</a><br>" >> $OUT_SIMULATE_FILE  
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
        isMACDNegativ=$(echo "$MACDAt" | awk '{print substr ($0, 0, 1)}')
        if [ "$valueRSI" -lt "$RSIBuyLevelParam" ] && [ "$isMACDNegativ" = '-' ]; then
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
                amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
                amount=$(printf "%.0f" "$amount")
                piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
                wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
                wallet=$(printf "%.0f" "$wallet")
                quoteAt=$(printf "%.2f" "$quoteAt")
                Out "Buy\tPos:$RSIindex\t""$piecesPerTrade""Pc\tRSI:$valueRSI\tQuote:$quoteAt€\tAmnt:$amount€\tPieces:$piecesHold\tWallet:$wallet€" $OUT_SIMULATE_FILE
                buyingDay=$((buyingDay + RSIindex))
                amountOfTrades=$((amountOfTrades + 1)) 

                lastLowestQuoteAt="$quoteAt" 
            fi     
            RSIBuyLevelParam=100              
        fi

        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        if [ "$piecesHold" -gt 0 ]; then                    
            amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
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
                    wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
                    wallet=$(printf "%.0f" "$wallet")
                    sellAmountOverAll=$(echo "$amount $sellAmountOverAll" | awk '{print ($1 + $2)}')
                    Out "Sell\tPos:$RSIindex\t""$piecesHold""pc\tStoch:$stochAt\tQuote:$quoteAt€\tAmnt:$amount€" $OUT_SIMULATE_FILE
                    Out "Intermediate Win=$wallet€ Perc=$intermediateProzWin% Avg Holding Days=$averageHoldingDays days" $OUT_SIMULATE_FILE
                    simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}')
                    piecesHold=0
                    wallet=0
                    amountPerTrade="$amountPerTradeParam"
                    amountOfTrades=0
                    buyingDay=0

                    lastLowestQuoteAt=$QUOTE_MAX_VALUE
                    RSIBuyLevelParam=$3
                fi
            fi
        fi
        RSIindex=$((RSIindex + 1))    
    done

    # Sell all on the last day, to get gid of all stocks for simulation
    if [ "$piecesHold" -gt 0 ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f 100 -d ',')" 
        Out "Sell all on the last day!!" $OUT_SIMULATE_FILE
        amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
        quoteAt=$(printf "%.2f" "$quoteAt")
        Out "Sell\t""$piecesHold""pc\tQuote:$quoteAt€\tAmnt=$amount€" $OUT_SIMULATE_FILE
        sellAmountOverAll=$(echo "$sellAmountOverAll $amount" | awk '{print ($1 + $2)}')
        intermediateProzWin=$(echo "$amount $wallet" | awk '{print (($1 / $2 * 100)-100)}')
        intermediateProzWin=$(printf "%.1f" "$intermediateProzWin")
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}') 
        Out "Intermediate Win=$wallet€ Perc=$intermediateProzWin%" $OUT_SIMULATE_FILE
        simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}') 
        lastLowestQuoteAt=$QUOTE_MAX_VALUE 
        RSIBuyLevelParam=$3
    fi

    Out "---------------" $OUT_SIMULATE_FILE
    Out "Sell Amount Overall=$sellAmountOverAll€" $OUT_SIMULATE_FILE
    Out "Simulation Win=$simulationWin€" $OUT_SIMULATE_FILE
    winOverAll=$(echo "$winOverAll $simulationWin" | awk '{print ($1 + $2)}')
    Out "" $OUT_SIMULATE_FILE
done

Out "" $OUT_SIMULATE_FILE
Out "===============" $OUT_SIMULATE_FILE
Out "Sell Amount Overall=$sellAmountOverAll€" $OUT_SIMULATE_FILE
Out "Win Overall=$winOverAll€" $OUT_SIMULATE_FILE
Out "Wallet Overall=$walletOverAll€" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE

creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
if [ "$(uname)" = 'Linux' ]; then
    creationDate=$(TZ=EST-1EDT date +"%e-%b-%Y %R") # +2h
fi

Out "Good Luck! Donate? $creationDate" $OUT_SIMULATE_FILE
Out "" $OUT_SIMULATE_FILE
echo "</body></html>" >> $OUT_SIMULATE_FILE
