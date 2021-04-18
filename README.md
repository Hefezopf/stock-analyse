# Stock Analyse
Automated Stock Analysis.

Shell script to check a list of given stock quotes and their averages of the last 95, 38, 18 days.

Stochastic, RSI and MACD are calculated as well.

Values are calculated on XETRA end-of-day quotes.

Html outputs with charts and alerts.

Alerts via email.

# Result
![ScreenShotResult](image/ScreenShotResult.png "ScreenShotResult")

## Outputs:
- out/SYMBOL.html
- out/_result.html
- out/_result_schedule.html


# Execute

## Run CMD CLI
./analyse.sh SYMBOLS PERCENTAGE QUERY STOCHASTIC RSI

./analyse.sh 'BEI' 1 online 9 30

./analyse.sh 'BEI ALV BAS' 2 offline 9 30

# CMD Output
![ScreenShotCMD](image/ScreenShotCMD.png "ScreenShotCMD")

## Github Action
https://github.com/Hefezopf/stock-analyse/actions


## Scheduled Cron Job
Scheduled Cron Jobs is pre configured in this action

https://github.com/Hefezopf/stock-analyse/blob/main/.github/workflows/schedule.workflow.yml


## cURL
./curl_github_dispatch_analyse.sh "BEI ALV" 1 offline 9 30

or Example cURL

curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "analyse", "client_payload": {"symbols": "BEI ALV", "percentage": "1", "query": "offline", "stochastic": "20", "RSI": "30"}}'

other cURLs

./curl_github_dispatch_buy.sh BEI 9.99

./curl_github_dispatch_sell.sh BEI


or via Apps

https://apps.apple.com/de/app/icurlhttp/id611943891

http://www.smallscreensystems.com/iCurl

{"event_type": "analyse", "client_payload": {"symbols": "BEI", "percentage": "1", "query": "offline", "stochastic": "9", "RSI":"30"}}

{"event_type": "sell", "client_payload": {"symbol": "BEI"}}

{"event_type": "buy", "client_payload": {"symbol": "BEI", "avg": "9.99"}}

# Available Stock Symbols

Available stock symbols are listed in config/stock_symbols.txt

# Own Stocks

Own stocks and average buying rate are listed in config/own_symbols.txt

Example:

HLE 45.29

DBK 14.741
...

# Change Portfolio

To change your portfolio edit the files in config dir or run the above cURL commands

# REST Calls

REST calls to external services
## Marketstack
curl  --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=BEI" | jq '.data[].close'

## OpenFIGI
curl --request POST 'https://api.openfigi.com/v2/mapping' --header 'Content-Type: application/json' --header 'echo ${X_OPENFIGI_APIKEY}' --data '[{"idType":"TICKER", "idValue":"'${1}'"}]' | jq '.[0].data[0].name'


