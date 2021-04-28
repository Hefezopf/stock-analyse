#!/bin/sh

# SimulateStrategieBuyRSILowMACDNegativ function:
# Strategie: xxx
# Input: ${x}
# Output: resultxxxx
SimulateStrategieBuyRSILowMACDNegativ() {
    #  _historyQuotesParam=${1}
    #  _historyMACDsParam=${2}
    #_amountPerTradeParam=${3}
    #  _RSIBuyLevelParam=${4}
    #  _incrementPerTradeParam=${5}

# export piecesHold
# export wallet
#export amountPerTrade
#export incrementPerTrade

    MACDAt="$(echo "$historyMACDs" | cut -f "$RSIindex" -d ',')"
    isMACDNegativ=$(echo "${MACDAt}" | awk '{print substr ($0, 0, 1)}')
   # echo valueRSI $valueRSI RSIBuyLevel $RSIBuyLevel  isMACDNegativ $isMACDNegativ
    if [ "$valueRSI" -lt "$RSIBuyLevelParam" ] && [ "${isMACDNegativ}" = '-' ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')"
        echo amountPerTrade "$amountPerTrade"
        amountPerTrade=$(echo "$amountPerTrade $incrementPerTrade" | awk '{print ($1 * $2)}')
        piecesPerTrade=$(echo "$amountPerTrade $quoteAt" | awk '{print ($1 / $2)}')
        echo amountPerTrade $amountPerTrade quoteAt $quoteAt piecesPerTrade $piecesPerTrade
        piecesPerTrade=${piecesPerTrade%.*}
        if [ "${piecesPerTrade}" -eq 0 ]; then
            piecesPerTrade=1
        fi
        amount=$(echo "$quoteAt $piecesPerTrade" | awk '{print ($1 * $2)}')
        piecesHold=$(echo "$piecesHold $piecesPerTrade" | awk '{print ($1 + $2)}')
        wallet=$(echo "$wallet $amount" | awk '{print ($1 + $2)}')
        echo -e "Buy\t"$piecesPerTrade"pc\tPosition:"$RSIindex"\tvalueRSI:"$valueRSI"\tQuote:"$quoteAt"€\tAmount="$amount"€\tpiecesHold=$piecesHold\tWallet=$wallet€" | tee -a $OUT_SIMULATE_FILE
    fi    
}

# SimulateStrategieSellStochHigh function:
# Strategie: xxx
# Input: ${x}
# Output: 
SimulateStrategieSellStochHigh() {
    # _historyQuotesParam=${1}
    # _historyMACDsParam=${2}
    # _amountPerTradeParam=${3}
    # _RSIBuyLevelParam=${4}
    # _incrementPerTradeParam=${5}

export piecesHold
export wallet
export amountPerTrade
export simulationWin

    stochAt="$(echo "$historyStochs" | cut -f "$RSIindex" -d ',')" 
    if [ "${piecesHold}" -gt 0 ] && [ "$stochAt" -gt "$StochSellLevelParam" ]; then
        quoteAt="$(echo "$historyQuotes" | cut -f "$RSIindex" -d ',')" 
        amount=$(echo "$quoteAt $piecesHold" | awk '{print ($1 * $2)}')
        echo -e "Sell\t"$piecesHold"pc\tPosition:"$RSIindex" stoch:"$stochAt" Quote:"$quoteAt"€ Amount="$amount"€" | tee -a $OUT_SIMULATE_FILE
        wallet=$(echo "$amount $wallet" | awk '{print ($1 - $2)}')
        echo "Intermediate win "$wallet"€" | tee -a $OUT_SIMULATE_FILE
        simulationWin=$(echo "$simulationWin $wallet" | awk '{print ($1 + $2)}')
        piecesHold=0
        wallet=0
        amountPerTrade="$amountPerTradeParam"
    fi
}
