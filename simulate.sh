#!/bin/sh

# This script simulates a given stock quote.
# Call: ./simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL 
# 1. Parameter: SYMBOL - Stock symbol like: 'BEI'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 30
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 70
# Call example: ./simulate.sh BEI 2000 30 70

# Parameter
symbolParam=$1
amountPerTradeParam=$2
RSIBuyLevelParam=$3
StockSellLevelParam=$4

HISTORY_FILE=history/"$symbolParam".txt
wallet=0
piecesHold=0

historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
historyStochs=$(head -n4 "$HISTORY_FILE" | tail -1)
historyRSIs=$(head -n6 "$HISTORY_FILE" | tail -1)
echo "$historyStochs"

# shellcheck disable=SC2001
RSIindex=1
for valueRSI in $(echo "$historyRSIs" | sed "s/,/ /g")
do
    # Buy
    if [ "$valueRSI" -lt "$RSIBuyLevelParam" ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        piecesPerTrade=$(echo "$amountPerTradeParam $quoteAt" | awk '{print ($1 / $2)}')
        piecesPerTrade=${piecesPerTrade%.*}
        amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
        piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
        wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
        echo buy "$piecesPerTrade" pieces: valueRSI:"$valueRSI" at positon:"$RSIindex" Quote:"$quoteAt"€ Amount="$amount"€ piecesHold=$piecesHold Wallet=$wallet€
    fi
    # Sell
    stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
    if [ "${piecesHold}" -gt 0 ] && [ "$stochAt" -gt "$StockSellLevelParam" ]; then
        echo ""
        echo stochAt "$stochAt" valueRSI "$valueRSI"
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
        echo sell "$piecesHold" piecesHold: valueRSI:"$valueRSI" at positon:"$RSIindex" Quote:"$quoteAt"€ Amount="$amount"€
        piecesHold=0
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
        echo wallet=$wallet€
    fi
    RSIindex=$((RSIindex + 1))
done
echo "-----------"
echo wallet=$wallet€
echo piecesHold=$piecesHold