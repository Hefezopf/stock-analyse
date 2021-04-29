#!/bin/sh

# This script simulates a given stock quote.
# Call: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# Call example: simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh 'BEI ALV' 2000 25 91 1.1

# Debug mode
#set -x

# Parameter
symbolsParam=$1
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StochSellLevelParam=$4
incrementPerTradeParam=$5

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

OUT_SIMULATE_FILE="out/_simulate.txt"
TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
#rm -rf "$OUT_SIMULATE_FILE"
export winOverall=0
walletOverAll=0

echo "" | tee -a $OUT_SIMULATE_FILE
echo "# Simulate BuyRSILowMACDNegativ SellHighStoch" | tee -a $OUT_SIMULATE_FILE
echo "#############################################" | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE
echo "# Parameter" | tee -a $OUT_SIMULATE_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam" | tee -a $OUT_SIMULATE_FILE
echo "Amount per Trade:$amountPerTradeParam€" | tee -a $OUT_SIMULATE_FILE
echo "RSI buy Level:$RSIBuyLevelParam" | tee -a $OUT_SIMULATE_FILE
echo "Stoch sell Level:$StochSellLevelParam" | tee -a $OUT_SIMULATE_FILE
echo "Increment per Trade:$incrementPerTradeParam" | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE

echo "# Simulation" | tee -a $OUT_SIMULATE_FILE

# Simulate stock for each symbol
for symbol in $symbolsParam
do
    amountOfTrades=0
    buyingDay=0
    wallet=0
    simulationWin=0
    piecesHold=0
    amountPerTrade=$amountPerTradeParam
    symbolName=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
    echo "" | tee -a $OUT_SIMULATE_FILE
    echo "$symbol $symbolName" | tee -a $OUT_SIMULATE_FILE
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
        isMACDNegativ=$(echo "${MACDAt}" | awk '{print substr ($0, 0, 1)}')
        if [ "$valueRSI" -lt "$RSIBuyLevelParam" ] && [ "${isMACDNegativ}" = '-' ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
            piecesPerTrade=$(echo "$amountPerTrade $quoteAt" | awk '{print ($1 / $2)}')
            amountPerTrade=$(echo "$amountPerTrade $incrementPerTradeParam" | awk '{print ($1 * $2)}')
            piecesPerTrade=${piecesPerTrade%.*}
            if [ "${piecesPerTrade}" -eq 0 ]; then
                piecesPerTrade=1
            fi
            amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
            piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
            wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
            echo -e "Buy\t""$piecesPerTrade""pc\tPosition:$RSIindex\tRSI:$valueRSI\tQuote:$quoteAt€\tAmount=$amount€\tpiecesHold=$piecesHold\tWallet=$wallet€\tSymbol:"$symbol"" | tee -a $OUT_SIMULATE_FILE

            buyingDay=$((buyingDay + RSIindex))
            amountOfTrades=$((amountOfTrades + 1))            
        fi

        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
        if [ "${piecesHold}" -gt 0 ] && [ "$stochAt" -gt "$StochSellLevelParam" ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
            amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
            echo -e "Sell\t""$piecesHold""pc\tPosition:$RSIindex\tStoch:$stochAt\tQuote:$quoteAt€\tAmount=$amount€\tSymbol:"$symbol"" | tee -a $OUT_SIMULATE_FILE
            
            averageBuyingDay=$(echo "$buyingDay $amountOfTrades" | awk '{print ($1 / $2)}')
            averageHoldingDays=$(echo "$RSIindex $averageBuyingDay" | awk '{print ($1 - $2)}')
            averageHoldingDays=$(printf "%.1f" "$averageHoldingDays")
            intermediateProzWin=$(echo "$amount $wallet" | awk '{print (($1 / $2 * 100)-100)}')
            intermediateProzWin=$(printf "%.1f" "$intermediateProzWin")
            wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
            echo "Intermediate Win=$wallet€ Proz=$intermediateProzWin% Average holding days=$averageHoldingDays days" | tee -a $OUT_SIMULATE_FILE
            simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}')

            piecesHold=0
            wallet=0
            amountPerTrade="$amountPerTradeParam"
            
            amountOfTrades=0
            buyingDay=0
        fi

        RSIindex=$((RSIindex + 1))    
    done

    # Sell all on the last day, to get gid of all stocks for simulation
    if [ "${piecesHold}" -gt 0 ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f 100 -d ',')" 
        echo "Sell all on the last day!!" | tee -a $OUT_SIMULATE_FILE
        amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
        echo -e "Sell\t""$piecesHold""pc\tQuote:$quoteAt€\tAmount=$amount€\tSymbol:"$symbol"" | tee -a $OUT_SIMULATE_FILE
        intermediateProzWin=$(echo "$amount $wallet" | awk '{print (($1 / $2 * 100)-100)}')
        intermediateProzWin=$(printf "%.1f" "$intermediateProzWin")
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}') 
        echo "Intermediate Win=$wallet€ Proz=$intermediateProzWin%" | tee -a $OUT_SIMULATE_FILE
        simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}')  
    fi

    echo "---------------" | tee -a $OUT_SIMULATE_FILE
    echo "Simulation Win=$simulationWin€" | tee -a $OUT_SIMULATE_FILE
    winOverAll=$(echo "$winOverAll $simulationWin" | awk '{print ($1 + $2)}')
    echo "" | tee -a $OUT_SIMULATE_FILE
done

echo "" | tee -a $OUT_SIMULATE_FILE
echo "===============" | tee -a $OUT_SIMULATE_FILE
echo "Win overall=$winOverAll€" | tee -a $OUT_SIMULATE_FILE
echo "Wallet overall=$walletOverAll€" | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE
