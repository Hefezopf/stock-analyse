#!/bin/bash

# This script simulates buy candidates.
# Call: simulate/simulate-buy-candidates.sh SYMBOL
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: LAST_DAYS: Consider the last X days; like 3
# 3. Parameter: CHAR_LENGTH_ALARM: How much characters; like 35
# Call example: ./simulate/simulate-buy-candidates.sh 'BEI HLE GZF TNE5' 3 35
# then: "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"

# Import
# shellcheck disable=SC1091
. script/constants.sh

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
lastDaysParam=$2
charactersParam=$3

if { [ -z "$symbolsParam" ] || [ -z "$lastDaysParam" ] || [ -z "$charactersParam" ]; } then
  echo "Not all parameters specified!"
  echo "Call: sh ./simulate/simulate-buy-candidates.sh SYMBOL LAST_DAYS CHAR_LENGTH_ALARM"
  echo "Example: sh ./simulate/simulate-buy-candidates.sh 'BEI HLE GZF TNE5' 3 35"
  exit 1
fi

rm -f ./simulate/simulate-buy-candidates-open-in-chrome.sh

countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo ""
echo "Symbols($countSymbols)"

rm -rf "$SIM_LAST_ALARMS_HTML_FILE"
HTML_FILE_HEADER="<!DOCTYPE html><html lang='en'>
<head>
<meta charset='utf-8' />
<meta http-equiv='cache-control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='pragma' content='no-cache' />
<meta http-equiv='expires' content='0' />
<link rel='shortcut icon' type='image/ico' href='favicon.ico' />
<link rel='stylesheet' href='_result.css' />
<title>Simulate Last Alarms</title>
</head>
<body>
<div>"
echo "$HTML_FILE_HEADER" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "Simulate Last '$lastDaysParam' Days with min '$charactersParam' Alarms:" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "<br><br>" >> "$SIM_LAST_ALARMS_HTML_FILE"

# Simulate stocks for each symbol
for symbol in $symbolsParam
do
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        symbol=$(echo "$symbol" | cut -b 2-7)
    fi
    lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
    symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
    echo "Symbol: $symbol"
    minRange=$((88-lastDaysParam))
    lastAlarms=$(cat alarm/$symbol.txt | cut -f "$minRange"-87 -d ',')
    #lastAlarms=$(cat alarm/$symbol.txt | cut -f 85-87 -d ',')
    if [ "${#lastAlarms}" -gt "$charactersParam" ]; then # Check if lastAlarms are large enough
        vorzeichen="${lastAlarms: -2 : -1}"
        if [ "$vorzeichen" = '+' ]; then # Check if lastAlarms buying values
            lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE")
            symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
            echo "Last '$lastDaysParam' Alarms for $symbol $symbolName: $lastAlarms" # Sample -> last 3 Alarms: 'C+5R+6S+M+','C+5R+6S+M+','C+5R+6S+M+'
            echo "start chrome https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh
            # TODO: if more then 50 -> build in!
            # echo "read -p 'Close Chrome manually and Press enter to continue the next 50'" >> ./simulate/simulate-buy-candidates-open-in-chrome.sh

            echo "<a href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html'>$symbol</a><br>" >> "$SIM_LAST_ALARMS_HTML_FILE"
        fi
    fi
done
echo "<br></div></body></html>" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo ""
if [ ! "$(uname)" = 'Linux' ]; then
    echo "./simulate/simulate-buy-candidates-open-in-chrome.sh" | clip
    echo "Call: ./simulate/simulate-buy-candidates-open-in-chrome.sh (in Clipboard)"
fi
echo "file:///D:/code/stock-analyse/simulate/out/_simulate_last_alarms.html"
echo "https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate_last_alarms.html"

