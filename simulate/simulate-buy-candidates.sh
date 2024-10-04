#!/bin/bash

# This script simulates buy candidates.
# Call: simulate/simulate-buy-candidates.sh SYMBOL
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: CHAR_LENGTH_ALARM: How much characters; like 35
# Call example: ./simulate/simulate-buy-candidates.sh 'BEI HLE GZF TNE5' 35
# then: "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
charactersParam=$2

if { [ -z "$symbolsParam" ] || [ -z "$charactersParam" ]; } then
  echo "Not all parameters specified!"
  echo "Call: sh ./simulate/simulate-buy-candidates.sh SYMBOL CHAR_LENGTH_ALARM"
  echo "Example: sh ./simulate/simulate-buy-candidates.sh 'BEI HLE GZF TNE5' 35"
  exit 1
fi

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
    if [ "${#lastAlarms}" -gt "$charactersParam" ]; then # Check if lastAlarms are large enough
        vorzeichen="${lastAlarms: -2 : -1}"
        if [ "$vorzeichen" = '+' ]; then # Check if lastAlarms buying values
            echo "Last 3 Alarms for '$symbol': $lastAlarms" # Sample -> last 3 Alarms: 'C+5R+6S+M+','C+5R+6S+M+','C+5R+6S+M+'
            echo "start chrome https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh

            # TODO: if more then 50 -> build in!
            # echo "read -p 'Close Chrome manually and Press enter to continue the next 50'" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh
        fi
    fi
done

echo "./simulate/simulate-buy-candidates-open-in-chrome.sh" | clip
echo "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"
