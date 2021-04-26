#!/bin/sh

# This script simulates a given stock quote.
# Call: ./simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL 
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# Call example: ./simulate.sh 'BEI ALV' 2000 25 91

# Parameter
symbolsParam=$1
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StockSellLevelParam=$4

winOverall=0
walletOverAll=0

# Simulate stock for each symbol
for symbol in $symbolsParam
do
    win=0
    wallet=0
    piecesHold=0
    echo "$symbol"
    HISTORY_FILE=history/"$symbol".txt
    historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
    historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)
    historyRSIs=$(head -n6 "$HISTORY_FILE" | tail -1)
    historyMACDs=$(head -n8 "$HISTORY_FILE" | tail -1)
#echo historyMACDs "$historyMACDs"

    # shellcheck disable=SC2001
    RSIindex=1
    for valueRSI in $(echo "$historyRSIs" | sed "s/,/ /g")
    do
        # Buy
        MACDAt="$(echo "$historyMACDs" | cut -f "$RSIindex" -d ',')"
        #echo MACDAt "$MACDAt"
        isMACDNegativ=$(echo "${MACDAt}" | awk '{print substr ($0, 0, 1)}')
        if [ "$valueRSI" -lt "$RSIBuyLevelParam" ] && [ "${isMACDNegativ}" = '-' ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
            piecesPerTrade=$(echo "$amountPerTradeParam $quoteAt" | awk '{print ($1 / $2)}')
            piecesPerTrade=${piecesPerTrade%.*}
            amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
            piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
            wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
            echo Buy " "$piecesPerTrade" at positon:"$RSIindex" pieces: valueRSI:"$valueRSI" Quote:"$quoteAt"€ Amount="$amount"€ piecesHold=$piecesHold Wallet=$wallet€"
        fi
        # Sell
        stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
        if [ "${piecesHold}" -gt 0 ] && [ "$stochAt" -gt "$StockSellLevelParam" ]; then
            quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
            amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
            echo Sell "$piecesHold" at positon:"$RSIindex" stochAt:"$stochAt" Quote:"$quoteAt"€ Amount="$amount"€
            piecesHold=0
            wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
            # Only one action in the early history! If will continue, will might buy at the very end and never sell!
            break;
        fi
        RSIindex=$((RSIindex + 1))
        if [ "${RSIindex}" -eq 70 ]; then
            # Abbort 10 before end
            break; 
        fi       
    done
    echo "-----------"
    if [ "${piecesHold}" -eq 0 ]; then
        echo win=$wallet€
        winOverAll=$(echo "$winOverAll $wallet" | awk '{print ($1 + $2)}')
    else
        echo NO TRADE
        echo wallet=$wallet€
        walletOverAll=$(echo "$walletOverAll $wallet" | awk '{print ($1 + $2)}')
    fi
    echo piecesHold=$piecesHold
    echo ""
done

echo ""
echo "=========="
echo winOverAll=$winOverAll
echo walletOverAll=$walletOverAll
