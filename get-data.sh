#!/bin/sh

# This script checks given stock quotes and their averages of the last 95, 38, 18 days.
# Stochastic, RSI and MACD are calculated as well
# Call: ./analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI
# 1. Parameter: SYMBOLS - List of stock symbols like: 'BEI *ALV BAS ...'; Stocks with prefix '*' are marked as own stocks 
# 2. Parameter: PERCENTAGE - Percentage difference; '3' means 3 percent.
# 3. Parameter: QUERY - [online|offline] 'offline' do not query via REST API.
# 4. Parameter: STOCHASTIC: Percentage for stochastic indicator (only single digit allowed!)
# 5. Parameter: RSI: Quote for RSI indicator (only 30 and less allowed!)
# Call example: ./analyse.sh 'BEI *ALV' 1 online 9 25
# Call example: ./analyse.sh 'BEI' 2 offline 9 25
# Call example: ./analyse.sh '*BEI' 1 offline 9 25
# Precondition:
# Set MARKET_STACK_ACCESS_KEY as ENV Variable (Online)
# Set GPG_PASSPHRASE as ENV Variable


# Debug mode
#set -x

# Import
# shellcheck disable=SC1091
. ./script/constants.sh
. ./script/functions.sh
. ./script/averages.sh
. ./script/strategies.sh

# Switches for calculating charts and underlying strategies. Default is 'true'
# 6th parameter is undocumented! Speeds up development!
if { [ -z "$6" ]; } then
    CalculateStochastic=true
    CalculateRSI=true
    CalculateMACD=true
fi

# Switches to turn on/off Strategies. Default is 'true'
ApplyStrategieByTendency=false
ApplyStrategieHorizontalMACD=true

# Settings for currency formating like ',' or '.' with 'printf'
export LC_ALL=en_US.UTF-8

export MARKET_STACK_ACCESS_KEY

# Parameter
symbolsParam=$1
percentageParam=$2
queryParam=$3
stochasticPercentageParam=$4
RSIQuoteParam=$5

# Prepare
lowestRSI=100
TEMP_DIR=/tmp
#TEMP_DIR=/dev/shm
rm -rf $TEMP_DIR/tmp.*
mkdir -p out
mkdir -p temp
cp template/favicon.ico out
OUT_RESULT_FILE=out/_result.html
rm -rf $OUT_RESULT_FILE
OWN_SYMBOLS_FILE=config/own_symbols.txt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" "$OWN_SYMBOLS_FILE".gpg 2>/dev/null
alarmAbbrevValue=""
TICKER_NAME_ID_FILE=config/ticker_name_id.txt
HTML_RESULT_FILE_HEADER="<!DOCTYPE html><html lang=\"en\"><head>
<meta charset=\"utf-8\" />
<meta http-equiv=\"cache-control\" content=\"max-age=0\" />
<meta http-equiv=\"cache-control\" content=\"no-cache\" />
<meta http-equiv=\"expires\" content=\"0\" />
<!-- <meta http-equiv=\"expires\" content=\"Tue, 01 Jan 1980 1:00:00 GMT\" /> -->
<meta http-equiv=\"pragma\" content=\"no-cache\" />
<link rel=\"shortcut icon\" type=\"image/ico\" href=\"favicon.ico\" />
<title>Result SA</title>
<style>.green{color:green;} .red{color:red;} .black{color:black;}
 /* iphone 3 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 1) {
body > div {
    font-size: xx-large;
}}
        
/* iphone 4 */
@media only screen and (min-device-width: 320px) and (max-device-height: 480px) and (-webkit-device-pixel-ratio: 2) {
body > div {
    font-size: xx-large;
}}

/* iphone 5 */
@media only screen and (min-device-width: 320px) and (max-device-height: 568px) and (-webkit-device-pixel-ratio: 2) {
body > div {
    font-size: xx-large;
}}

/* iphone 6, 6s, 7, 8 */
@media only screen and (min-device-width: 375px) and (max-device-height: 667px) and (-webkit-device-pixel-ratio: 2) {
    body > div {
    font-size: xx-large;
}}
    
/* iphone 6+, 6s+, 7+, 8+ */
@media only screen and (min-device-width: 414px) and (max-device-height: 736px) and (-webkit-device-pixel-ratio: 3) { body > div {
    font-size: xx-large;
  }}

/* iphone X , XS, 11 Pro, 12 Mini */
@media only screen and (min-device-width: 375px) and (max-device-height: 812px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
    font-size: xx-large;
}}

/* iphone 12, 12 Pro */
@media only screen and (min-device-width: 390px) and (max-device-height: 844px) and (-webkit-device-pixel-ratio: 3) {
    body > div {
    font-size: x-large;
}}

/* iphone XR, 11 */
@media only screen and (min-device-width : 414px) and (max-device-height : 896px) and (-webkit-device-pixel-ratio : 2) {body > div {
    font-size: x-large;
  } }
    
/* iphone XS Max, 11 Pro Max */
@media only screen and (min-device-width : 414px) and (max-device-height : 896px) and (-webkit-device-pixel-ratio : 3) {
    body > div {
    font-size: x-large;
}}

/* iphone 12 Pro Max */
@media only screen and (min-device-width : 428px) and (max-device-height : 926px) and (-webkit-device-pixel-ratio : 3) {
    body > div {
    font-size: x-large;
}}
</style>
</head>
<body>
<div>
<script>
    var token = 'ghp' + '_' + 'fWYED11UzfLqo8gZ0dBvVC8yTZj7F00SeEQB';
    function curlBuy(symbolParam, price, pieces) {
        if(symbolParam == '' || price == '' || pieces == ''){
            alert('Error: Symbol, Price or Pieces not set!');
            return;
        }     
        var symbolParamTrimmed = symbolParam.trim();
        var price = parseFloat(price.replace(',', '.')).toFixed(2);
        var pieces = pieces.replace('.', '');  
        if (confirm('Buy ' + pieces + ' pieces of ' + symbolParamTrimmed + '=' + (pieces*price).toFixed(0) + '€?') == false) {
            return;
        }
        if(document.getElementById('intervalSectionInputPriceBuy'+symbolParamTrimmed)){
            document.getElementById('intervalSectionInputPriceBuy'+symbolParamTrimmed).value = '';
        }
        if(document.getElementById('intervalSectionInputPiecesBuy'+symbolParamTrimmed)){
            document.getElementById('intervalSectionInputPiecesBuy'+symbolParamTrimmed).value = '';
        }        
        document.getElementById('intervalSectionInputSymbolBuyGenerell').value = '';
        document.getElementById('intervalSectionInputPriceBuyGenerell').value = '';
        document.getElementById('intervalSectionInputPiecesBuyGenerell').value = '';

        var url = 'https://api.github.com/repos/Hefezopf/stock-analyse/dispatches';
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url);
        xhr.setRequestHeader('Authorization', 'token ' + token);
        xhr.setRequestHeader('Accept', 'application/vnd.github.everest-preview+json');
        xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            console.log(xhr.status);
            console.log(xhr.responseText);
        }};
        var data = {
            event_type: 'buy', 
            client_payload: {
                symbol: symbolParamTrimmed, 
                pieces: pieces,
                price: price,            
            }
        };
        xhr.send(JSON.stringify(data));
    }    
    function curlSell(symbolParam) {          
        if (confirm('Sell ' + symbolParam + '?') == false) {
            return;
        }
        var url = 'https://api.github.com/repos/Hefezopf/stock-analyse/dispatches';
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url);
        xhr.setRequestHeader('Authorization', 'token ' + token);
        xhr.setRequestHeader('Accept', 'application/vnd.github.everest-preview+json');
        xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            console.log(xhr.status);
            console.log(xhr.responseText);
        }};
        var data = {
            event_type: 'sell', 
            client_payload: {
                symbol: symbolParam
            }
        };
        xhr.send(JSON.stringify(data));
    }
    function decryptElement(ele) {
        var dec = document.getElementById(ele.id).innerHTML;
        dec = dec.split(\"\").reverse().join(\"\"); // reverseString
        dec = replaceInString(dec);
        document.getElementById(ele.id).innerHTML = dec;
    }
    function replaceInString(str){
        var ret = str.replace(/XX/g, \" pc \");
        var ret = ret.replace(/YY/g, \"€ \");
        return ret.replace(/ZZ/g, \"% \");
    }    
</script>"
echo "$HTML_RESULT_FILE_HEADER" > $OUT_RESULT_FILE
creationDate=$(date +"%e-%b-%Y %R") # 29-Apr-2021 08:52
if [ "$(uname)" = 'Linux' ]; then
    creationDate=$(TZ=EST-0EDT date +"%e-%b-%Y %R") # +2h
fi
GOOD_LUCK="<p style=\"text-align: right; padding-right: 50px\">Good Luck! <a href=\"https://www.paypal.com/donate/?hosted_button_id=G2CERK22Q4QP8\" target=\"_blank\">Donate?</a> $creationDate</p>"
HTML_RESULT_FILE_END="$GOOD_LUCK<br></div>
<script>
    var sound=$SOUND; // Only once assigned, for all beeps

    // Show link if on PC
    if(location.href.startsWith('file')){
        linkPCValues = document.querySelectorAll('[id ^= \"linkPC\"]');
        Array.prototype.forEach.call(linkPCValues, revealElement);
    }

    var toggleIsVisible = false;
    var toggleDecryptOnlyOnce = false;
    document.getElementsByTagName('body')[0].ondblclick = processAll;
    function processAll(ele) { 
        intervalValues = document.querySelectorAll('[id ^= \"intervalSection\"]');
        obfuscatedValues = document.querySelectorAll('[id ^= \"obfuscatedValue\"]');
        if (toggleIsVisible === false) {
            Array.prototype.forEach.call(intervalValues, revealElement);
            Array.prototype.forEach.call(obfuscatedValues, revealElement);
            if (toggleDecryptOnlyOnce === false) {
                Array.prototype.forEach.call(obfuscatedValues, decryptElement);
                toggleDecryptOnlyOnce = true;
            }
            toggleIsVisible = true;
        }
        else {
            Array.prototype.forEach.call(intervalValues, hideElement);
            Array.prototype.forEach.call(obfuscatedValues, hideElement);
            toggleIsVisible = false;
        }
    }
    function revealElement(ele) {
        ele.style.display = '';
    } 
    function hideElement(ele) {
        ele.style.display = 'none';
    }   
</script>
</body></html>"
START_TIME_MEASUREMENT=$(date +%s);

# Check for multiple identical symbols in cmd. Do not ignore '*'' 
if echo "$symbolsParam" | tr -d '*' | tr '[:lower:]' '[:upper:]' | tr " " "\n" | sort | uniq -c | grep -v '^ *1 '; then
    echo "WARNING: Multiple symbols in parameter list!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
fi

# Usage: Check parameter
UsageCheckParameter "$symbolsParam" "$percentageParam" "$queryParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE

if [ ! "$CalculateStochastic" = true ] || [ ! "$CalculateRSI" = true ] || [ ! "$CalculateMACD" = true ]; then
    echo "WARNING: CalculateStochastic or CalculateRSI or CalculateMACD NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br><br>" >> $OUT_RESULT_FILE
    ApplyStrategieHorizontalMACD=false
fi

if { [ -z "$GPG_PASSPHRASE" ]; } then
    echo "Error GPG_PASSPHRASE NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 6
fi

if { [ "$queryParam" = 'online' ]; } &&
   { [ -z "$MARKET_STACK_ACCESS_KEY" ]; } then
    echo "Error 'online' query: MARKET_STACK_ACCESS_KEY NOT set!" | tee -a $OUT_RESULT_FILE
    echo "<br>" >> $OUT_RESULT_FILE
    echo "$HTML_RESULT_FILE_END" >> $OUT_RESULT_FILE
    exit 8
fi

percentageLesserFactor=$(echo "100 $percentageParam" | awk '{print ($1 + $2)/100}')
percentageGreaterFactor=$(echo "100 $percentageParam" | awk '{print ($1 - $2)/100}')

# RSI percentage
RSIQuoteLower=$RSIQuoteParam
RSIQuoteUpper=$((100-RSIQuoteParam))

# Stochastics percentage
stochasticPercentageLower=$stochasticPercentageParam
stochasticPercentageUpper=$((100-stochasticPercentageParam))

echo "# Parameter" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
countSymbols=$(echo "$symbolsParam" | awk -F" " '{print NF-1}')
countSymbols=$((countSymbols + 1))
echo "Symbols($countSymbols):$symbolsParam" | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Percentage:$percentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Query:$queryParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "Stochastic:$stochasticPercentageParam " | tee -a $OUT_RESULT_FILE
echo "<br>" >> $OUT_RESULT_FILE
echo "RSI:$RSIQuoteParam" | tee -a $OUT_RESULT_FILE
echo "<br><br># Analyse" >> $OUT_RESULT_FILE

# Analyse stock data for each symbol
for symbol in $symbolsParam
do
    # Stocks with prefix '*' are marked as own stocks
    markerOwnStock=""
    if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
        markerOwnStock="*"
        symbol=$(echo "$symbol" | cut -b 2-6)
    fi

    symbolExists=$(grep -n "$symbol" config/stock_symbols.txt)
    if [ "$symbolExists" ]; then
        echo ""
        echo Skip, because "$symbol" exists!
    else
        # Get stock data
        echo ""
        echo "# Get $symbol"
        DATA_FILE="$(mktemp -p $TEMP_DIR)"
        DATA_DATE_FILE=data/$symbol.txt
        if [ "$queryParam" = 'online' ]; then
            #tag=$(date +"%s") # Second -> date +"%s" ; Day -> date +"%d"
            DATA_DATE_FILE_TEMP="$(mktemp -p $TEMP_DIR)"
        # cp "$DATA_DATE_FILE" "$DATA_DATE_FILE_TEMP"
            # https://marketstack.com/documentation
            #exchange="XFRA" # Frankfurt
            exchange="XETRA"
            curl -s --location --request GET "https://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=${exchange}&symbols=${symbol}.${exchange}&limit=100" | jq -jr '.data[]|.date, "T", .close, "\n"' | awk -F'T' '{print $1 "\t" $3}' > "$DATA_DATE_FILE"
            # With volume
            # curl -s --location --request GET "https://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=${exchange}&symbols=${symbol}.${exchange}&limit=100" | jq -jr '.data[]|.date, "T", .close, "T", .volume, "\n"' | awk -F'T' '{print $1 "\t" $3 "\t" $4}' > "$DATA_DATE_FILE"
            fileSize=$(stat -c %s "$DATA_DATE_FILE")
            if [ "$fileSize" -eq "0" ]; then
                echo "<br>" >> $OUT_RESULT_FILE
                echo "!!! $symbol NO data retrieved online; Maybe CURL is blocked?" | tee -a $OUT_RESULT_FILE
                echo "<br>" >> $OUT_RESULT_FILE
            # mv "$DATA_DATE_FILE_TEMP" "$DATA_DATE_FILE"
            fi
        fi

        yesterday=$(date --date="-1 day" +"%Y-%m-%d")
        quoteDate=$(head -n1 "$DATA_DATE_FILE" | awk '{print $1}')
        if [ "$quoteDate" = "$yesterday" ]; then # OK, quote from last trading day
            echo "OK, quote from last trading day"
            symbolsWithData=$(echo "$symbol $symbolsWithData")
            CurlSymbolName "$symbol" $TICKER_NAME_ID_FILE 2
        else # NOK!
            echo "remove $symbol" 
            rm -rf "$DATA_DATE_FILE"
        fi
    fi
done

echo ""
echo "symbolsWithData="$symbolsWithData""

END_TIME_MEASUREMENT=$(date +%s);
echo ""
echo $((END_TIME_MEASUREMENT-START_TIME_MEASUREMENT)) | awk '{print int($1/60)":"int($1%60)}'
echo "time elapsed."
