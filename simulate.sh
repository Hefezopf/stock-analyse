#!/bin/sh

# This script simulates a given stock quote.
# Call: ./simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# Call example: ./simulate.sh 'BEI ALV' 2000 25 91 1.1

# Parameter
symbolsParam=$1
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StochSellLevelParam=$4
incrementPerTradeParam=$5

OUT_SIMULATE_FILE="out/_simulate.txt"
TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
rm -rf "$OUT_SIMULATE_FILE"
winOverall=0
walletOverAll=0

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
    win=0
    wallet=0
    piecesHold=0
    amountPerTrade=$amountPerTradeParam
    symbolName=$(grep -m1 -P "$symbol\t" "$TICKER_NAME_ID_FILE" | cut -f 2)
    echo "$symbol $symbolName" | tee -a $OUT_SIMULATE_FILE
    HISTORY_FILE=history/"$symbol".txt
    historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
    historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)
    historyRSIs=$(head -n6 "$HISTORY_FILE" | tail -1)
    historyMACDs=$(head -n8 "$HISTORY_FILE" | tail -1)

    # shellcheck disable=SC2001
    RSIindex=1
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
            amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
            piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
            wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
            echo -e "Buy\t"$piecesPerTrade"pc\tpositon:"$RSIindex"\tvalueRSI:"$valueRSI"\tQuote:"$quoteAt"€\tAmount="$amount"€\tpiecesHold=$piecesHold\tWallet=$wallet€" | tee -a $OUT_SIMULATE_FILE
        fi
        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
        if [ "${piecesHold}" -gt 0 ] && [ "$stochAt" -gt "$StochSellLevelParam" ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
            amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
            echo -e "Sell\t"$piecesHold"pc\tpositon:"$RSIindex" stochAt:"$stochAt" Quote:"$quoteAt"€ Amount="$amount"€" | tee -a $OUT_SIMULATE_FILE
            piecesHold=0
            wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
            # Only one action in the early history! If will continue, will might buy at the very end and never sell!
            break;
        fi
        RSIindex=$((RSIindex + 1))    
    done

    # Sell all at the last day to get gid of all stocks for simulation
    if [ "${piecesHold}" -gt 0 ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f 100 -d ',')" 
        echo "Sell all at the last day!!" | tee -a $OUT_SIMULATE_FILE
        amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
        echo -e "Sell\t"$piecesHold"pc\tQuote:"$quoteAt"€\tAmount="$amount"€" | tee -a $OUT_SIMULATE_FILE
        piecesHold=0
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')    
    fi

    echo "-----------" | tee -a $OUT_SIMULATE_FILE
    if [ "${piecesHold}" -eq 0 ]; then
        echo win=$wallet€ | tee -a $OUT_SIMULATE_FILE
        winOverAll=$(echo "$winOverAll $wallet" | awk '{print ($1 + $2)}')
    else
        echo NO TRADE | tee -a $OUT_SIMULATE_FILE
        echo wallet=$wallet€ | tee -a $OUT_SIMULATE_FILE
        walletOverAll=$(echo "$walletOverAll $wallet" | awk '{print ($1 + $2)}')
    fi
    echo "" | tee -a $OUT_SIMULATE_FILE
done

echo "" | tee -a $OUT_SIMULATE_FILE
echo "==========" | tee -a $OUT_SIMULATE_FILE
echo winOverAll=$winOverAll | tee -a $OUT_SIMULATE_FILE
echo walletOverAll=$walletOverAll | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE
echo "" | tee -a $OUT_SIMULATE_FILE
