#!/bin/sh

# This script simulates a given stock quote.
# Call: ./simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL RSI_SELL_LEVEL 
# 1. Parameter: SYMBOL - Stock symbol like: 'BEI'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 30
# 4. Parameter: RSI_SELL_LEVEL: RSI level when the selling trade will be trigged: like 70
# Call example: ./simulate.sh BEI 2000 30 70

# Parameter
symbolParam=$1
amountPerTradeParam=$2
RSI_buyLevelParam=$3
RSI_sellLevelParam=$4

HISTORY_FILE=history/"$symbolParam".txt
wallet=0
pieces=0

historyQuotes=$(head -n2 "$HISTORY_FILE" | tail -1)
echo "$historyQuotes"

echo ""

historyRSIs=$(head -n4 "$HISTORY_FILE" | tail -1)
echo "$historyRSIs"

# shellcheck disable=SC2001
MACDindex=0
for valueMACD in $(echo "$historyRSIs" | sed "s/,/ /g")
do
    if [ "$valueMACD" -lt "$RSI_buyLevelParam" ]; then
        #echo buying...
        quoteAt="$(echo "$historyQuotes" | cut -f "$MACDindex" -d ',')" 
        amount=$(echo "$quoteAt 100" | awk '{print ($1 * $2)}')
        pieces=$(echo "$pieces 100" | awk '{print ($1 + $2)}')
        wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
        echo buy 100 pieces: MACD:"$valueMACD" at positon:"$MACDindex" Quote:"$quoteAt"€ Amount="$amount"€ Wallet=$wallet€
    fi
    if [ "$wallet" -gt 0 ] && [ "$valueMACD" -gt "$RSI_sellLevelParam" ]; then
        #echo selling...
        quoteAt="$(echo "$historyQuotes" | cut -f "$MACDindex" -d ',')" 
        amount=$(echo "$quoteAt $pieces" | awk '{print ($1 * $2)}')
        echo sell $pieces pieces: MACD:"$valueMACD" at positon:"$MACDindex" Quote:"$quoteAt"€ Amount="$amount"€
        pieces=0
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
    fi
    MACDindex=$((MACDindex + 1))
done
echo "-----------"
echo wallet=$wallet€
echo pieces=$pieces