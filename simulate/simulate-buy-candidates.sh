#!/bin/bash

# This script simulates buy candidates.
# Call: simulate/simulate-buy-candidates.sh SYMBOL
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# Call example: simulate/simulate-buy-candidates.sh 'BEI HLE GZF TNE5'
# then: "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')

rm -f ./simulate/simulate-buy-candidates-open-in-chrome.sh

countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo ""
echo "Symbols($countSymbols)"

# Simulate stocks for each symbol
for symbol in $symbolsParam
do
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-7)
    fi
    echo "Symbol: $symbol"
    lastAlarms=$(cat alarm/$symbol.txt | cut -f 85-87 -d ',')
    if [ "${#lastAlarms}" -gt 35 ]; then # Check if lastAlarms are large enough
        vorzeichen="${lastAlarms: -2 : -1}"
        if [ "$vorzeichen" = '+' ]; then # Check if lastAlarms buying values
            echo "last 3 Alarms: $lastAlarms"
            echo "start chrome https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh

            # TODO: if more then 50 -> build in!
            # echo "read -p 'Close Chrome manually and Press enter to continue the next 50'" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh
        fi
    fi
done

echo "./simulate/simulate-buy-candidates-open-in-chrome.sh" | clip
echo "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"
