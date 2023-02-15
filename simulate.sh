#!/bin/bash

# This script simulates a given stock quote.
# Call: . simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 91
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# 7. Parameter: KEEP_IF_UNDER_PERCENTAGE: Keep if position is under this value: like 1 means 1% or more gain -> not sell.
# Call example: . simulate.sh 'BEI ALV' 2000 25 91 1.1 5 1
# Call example: . simulate.sh 'BEI' 2500 14 70 1.05 5 2
# Grep output to find symbols: grep Position:100 simulate/out/_simulate.html

# Debug mode
#set -x

OUT_SIMULATE_FILE="simulate/out/_simulate.html"
OUT_SIMULATE_OLD_FILE="simulate/out/_simulate_old.html"
cp "$OUT_SIMULATE_FILE" "$OUT_SIMULATE_OLD_FILE"
rm -rf "$OUT_SIMULATE_FILE"

#                                                        SYMBOLS
#                                                             AMOUNT_PER_TRADE
#                                                                  RSI_BUY_LEVEL
#                                                                       STOCH_SELL_LEVEL
#                                                                            INCREMENT_PER_TRADE
#                                                                               SELL_IF_OVER_PERCENTAGE
#                                                                                   KEEP_IF_UNDER_PERCENTAGE
#X_TIMES_AMOUNT_PER_TRADE=$(echo "$2" | awk '{print $1 * 2}')

. simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7"

#. simulate/simulate-buyRSILowDivergent-sellHighStoch.sh "$1" "$X_TIMES_AMOUNT_PER_TRADE" "$3" "$4" "$5" "$6" "$7"

#. simulate/simulate-buyRSILowMACDNegativ-sellHighStoch.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7"
