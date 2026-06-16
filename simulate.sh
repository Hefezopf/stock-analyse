#!/bin/bash

# This script simulates a given stock quote.
# Call: . simulate.sh SYMBOL AMOUNT_PER_TRADE RSI_BUY_LEVEL STOCH_SELL_LEVEL INCREMENT_PER_TRADE
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: AMOUNT_PER_TRADE: How much money will be spent on a single trade; like 2000€
# 3. Parameter: RSI_BUY_LEVEL: RSI level when the buying trade will be trigged: like 25
# 4. Parameter: STOCH_SELL_LEVEL: Stoch level when the selling trade will be trigged: like 90
# 5. Parameter: INCREMENT_PER_TRADE: Factor how many more stock to buy on each subsequent order: like 1.1 mean 10% more.
# NOT USED!!! -----# 6. Parameter: SELL_IF_OVER_PERCENTAGE: Sell if position is over this value: like 5 means 5% or more gain -> sell.
# 6. Parameter: KEEP_IF_UNDER_PERCENTAGE: Keep if position is under this value: like 1 means 1% or more gain -> not sell.
# NOT USED!!! -----# 8. Parameter: ALARM_COUNT_FOR_STOCK: Buy, if count is true for alarm. Like: 'C+4R+7S+P+D+N+M+' = 7 times '+'
# NOT USED!!! -----# 9. Parameter: ALARM_COUNT_FOR_INDEX: Buy, if count is true for alarm. Like: '7S+P+D+N+M+' = 5 times '+'
# 7. Parameter: ALARM_PATTERN: Buy, if pattern matches for the last day. Like: '+7R'
# Call example: . simulate.sh 'BEI ALV' 3000 25 90 1.05 99 2 7 5 '+7R'
# Call example: . simulate.sh 'BEI' 3000 25 90 1.01 99 1 7 5 '+7R'
# Hint: Grep output to find symbols -> grep Position:100 simulate/out/_simulate.html

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
#                                                                               SELL_IF_OVER_PERCENTAGE (NOT USED!!!)
#                                                                                   KEEP_IF_UNDER_PERCENTAGE
#                                                                                       ALARM_COUNT_FOR_STOCK
#                                                                                           ALARM_COUNT_FOR_INDEX
#                                                                                               ALARM_PATTERN

#./simulate/simulate-buyLowMACDNegativ-sellHighStoch.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
./simulate/simulate-buy-x-RSI-sellHighStoch.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" 

