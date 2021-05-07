#!/bin/sh

# This script simulates a given stock quote.
# Call: ./simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# Call example: ./simulate.sh 'BEI ALV' 2000 25 91 1.1
# Grep output to find symbols: grep Position:100 out/_simulate.txt

# Debug mode
#set -x

OUT_SIMULATE_FILE="out/_simulate.txt"
rm -rf "$OUT_SIMULATE_FILE"

#                                                        SYMBOL
#                                                             AMOUNT_PER_TRADE
#                                                                  RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
#                                                                       STOCH_SELL_LEVEL INCREMENT_PER_TRADE
#                                                                            INCREMENT_PER_TRADE
X_TIMES_AMOUNT_PER_TRADE=$(echo "$2" | awk '{print $1 * 2}')
./simulate/simulate-buyRSILowDivergent-sellHighStoch.sh "$1" "$X_TIMES_AMOUNT_PER_TRADE" "$3" "$4" "$5"

./simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh "$1" "$2" "$3" "$4" "$5"
