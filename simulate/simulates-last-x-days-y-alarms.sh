#!/bin/bash

# This script simulates buy candidates.
# Call: simulate/simulates-last-x-days-y-alarms.sh SYMBOL
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI ALV BAS ...'
# 2. Parameter: LAST_DAYS: Consider the last X days; like 3
# 3. Parameter: ALARM_CHARS: How much alarm characters; like 35
# Call example: ./simulate/simulates-last-x-days-y-alarms.sh 'BEI HLE GZF TNE5' 3 35
# then: "Call: ./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh (in Clipboard)"

# Import
# shellcheck disable=SC1091
. script/constants.sh
. script/functions.sh

START_TIME_MEASUREMENT=$(date +%s);

# Parameter
symbolsParam=$(echo "$1" | tr '[:lower:]' '[:upper:]')
lastDaysParam=$2
alarmCharactersParam=$3

if { [ -z "$symbolsParam" ] || [ -z "$lastDaysParam" ] || [ -z "$alarmCharactersParam" ]; } then
  echo "Error: Not all parameters specified!"
  echo "Call: sh ./simulate/simulates-last-x-days-y-alarms.sh SYMBOL LAST_DAYS ALARM_CHARS"
  echo "Example: sh ./simulate/simulates-last-x-days-y-alarms.sh 'BEI HLE GZF TNE5' 3 35"
  exit 1
fi

mkdir -p "$TEMP_DIR/config"
cp "$TICKER_NAME_ID_FILE" "$TEMP_DIR/config"

rm -f ./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh

countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo ""
echo "# SA Simulate Last X Days, with minimum Y Alarms"
echo ""
echo "Symbols($countSymbols)"

rm -rf "$SIM_LAST_ALARMS_HTML_FILE"
HTML_FILE_HEADER="<!DOCTYPE html><html lang='en'>
<head>
<meta charset='utf-8' />
<meta http-equiv='cache-control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='pragma' content='no-cache' />
<meta http-equiv='expires' content='0' />
<link rel='icon' type='image/x-icon' href='favicon.ico' />
<title>Simulate Last Alarms</title>

<style type='text/css'>
/* iPhone 3 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 1) {
    body > div {
        font-size: xx-large;
    }
}
        
/* iPhone 4 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 5 */
@media only screen and (min-device-width: 320px) and (max-device-height: 568px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 6, 6s, 7, 8 */
@media only screen and (min-device-width: 375px) and (max-device-height: 667px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone 6+, 6s+, 7+, 8+ */
@media only screen and (min-device-width: 414px) and (max-device-height: 736px) and (-webkit-device-pixel-ratio: 3) { 
    body > div {
        font-size: xx-large;
    }
}

/* iPhone X, XS, 11 Pro, 12 Mini */
@media only screen and (min-device-width: 375px) and (max-device-height: 812px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro, 14 Mini (Meines 2023) */
@media only screen and (min-device-width: 390px) and (max-device-height: 844px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        width: 25em;
        font-size: xx-large;
    }
}

/* iPhone XR, 11 */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
        font-size: xx-large;
    }
}
    
/* iPhone XS Max, 11 Pro Max */
@media only screen and (min-device-width: 414px) and (max-device-height: 896px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 12 Pro Max */
@media only screen and (min-device-width: 428px) and (max-device-height: 926px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
        font-size: xx-large;
    }
}

/* iPhone 16 (Meines 09/2024) */
@media only screen and (min-device-width: 393px) and (max-device-height: 852px) and (-webkit-device-pixel-ratio: 3) {
    body {
        font-size: 340%;
    }
}

/* Safari */
@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>

</head>
<body>
<script>var linkMap = new Map();</script>
<script type='text/javascript' src='_result.js'></script>
<div>"
# shellcheck disable=SC2129
echo "$HTML_FILE_HEADER" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "Simulate Last '$lastDaysParam' Days,<br>with minimum '$alarmCharactersParam' Alarms:" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "<br><br>" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "<button id='intervalSectionButtonOpenAll' style='font-size:x-large; height: 60px; width: 110px;' type='button' onClick='javascript:doOpenAllInTab()'>Open All</button><br><br>" >> "$SIM_LAST_ALARMS_HTML_FILE"

# Simulate stocks for each symbol
for symbol in $symbolsParam
do
    if [ "${symbol::1}" = '*' ]; then 
        symbol="${symbol:1:7}"
    fi

    #echo "Symbol: $symbol"
    minRange=$((88-lastDaysParam))
    # shellcheck disable=SC2002
    lastAlarms=$(cat alarm/"$symbol".txt | cut -f "$minRange"-87 -d ',')
    if [ "${#lastAlarms}" -gt "$alarmCharactersParam" ]; then # Check if lastAlarms are large enough
        vorzeichen="${lastAlarms: -2 : -1}"
        if [ "$vorzeichen" = '+' ]; then # Check if lastAlarms buying values
            lineFromTickerFile=$(grep -m1 -P "^$symbol\t" "$TICKER_NAME_ID_FILE_MEM")
            symbolName=$(echo "$lineFromTickerFile" | cut -f 2)
            ID_NOTATION=$(echo "$lineFromTickerFile" | cut -f 3)
            echo "$symbol $symbolName last '$lastDaysParam' alarms: $lastAlarms" # Sample -> last 3 Alarms: 'C+5R+6S+M+','C+5R+6S+M+','C+5R+6S+M+'
            echo "start chrome https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html" >> ./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh
            echo "<script>linkMap.set('$symbol', 'https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/""$symbol"".html'); // Open in Tab </script>" >> "$SIM_LAST_ALARMS_HTML_FILE"

            # TODO: if more then 50 -> build in!
            # echo "read -r -p 'Close Chrome manually and Press enter to continue the next 50'" >> ./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh

            # Market Cap
            marketCapFromFile=$(echo "$lineFromTickerFile" | cut -f 4)
            asset_type=$(echo "$lineFromTickerFile" | cut -f 9)
            lowMarketCapLinkBackgroundColor="white"
            if [ "$marketCapFromFile" = '?' ] && [ "$asset_type" = 'STOCK' ]; then
                lowMarketCapLinkBackgroundColor="rgba(251, 225, 173)"
            fi
            # echo "<div>" >> "$SIM_LAST_ALARMS_HTML_FILE"
            # echo "<img class='imgborder' id='imgToReplace$symbol' alt='' loading='lazy' src='https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=$ID_NOTATION&TIME_SPAN=10D' style='display:none;position:fixed;'/>" >> "$SIM_LAST_ALARMS_HTML_FILE"
            # echo "<a style='font-size: xxx-large; background:$lowMarketCapLinkBackgroundColor;' onmouseover=\"javascript:showChart('10D', '$symbol')\" onmouseout=\"javascript:hideChart('$symbol')\" href='https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/out/$symbol.html' target='_blank'>$symbol $symbolName</a><br><br>" >> "$SIM_LAST_ALARMS_HTML_FILE"
            # echo "</div>" >> "$SIM_LAST_ALARMS_HTML_FILE"
            WriteComdirectUrlAndStoreFileList "$SIM_LAST_ALARMS_HTML_FILE" "$symbol" "$symbolName" "$BLACK" "" "" "$lowMarketCapLinkBackgroundColor" "" "$ID_NOTATION"
        fi
    fi
done

GetCreationDate
# shellcheck disable=SC2154
echo "<br>Good Luck! $creationDate" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo "<br></div>
<script>
// Open all in Tabs
function doOpenAllInTab() {
    for (let [key, value] of linkMap) {
        window.open(value, '_blank');
    }
}
</script>
</body></html>" >> "$SIM_LAST_ALARMS_HTML_FILE"
echo ""
if [ ! "$(uname)" = 'Linux' ]; then
    echo "./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh" | clip
    echo "Call: ./simulate/simulates-last-x-days-y-alarms-open-in-chrome.sh (in Clipboard)"
fi

if [ "$(uname)" = 'Linux' ]; then
    echo "file:///media/markus/BigBerta/code/stock-analyse/simulate/out/_simulate_last_alarms.html"
else
    echo "file:///C:/code/stock-analyse/simulate/out/_simulate_last_alarms.html"
fi
echo "https://htmlpreview.github.io/?https://github.com/Hefezopf/stock-analyse/blob/main/simulate/out/_simulate_last_alarms.html"

rm -rf "$TEMP_DIR"/config

# Time measurement
END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."