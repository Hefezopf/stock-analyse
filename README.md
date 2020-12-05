# Stock Analyse
Automated Stock Analysis.

This script checks given stock quotes and their averages of the last 100, 38, 18 days.


# Run

## CMD
./analyse.sh SYMBOLS PERCENTAGE QUERY RATED STOCHASTIC

./analyse.sh 'ADS.XETRA' 1 online overrated 30

./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA' 2 offline underrated 20


## Github Action

https://github.com/Hefezopf/stock-analyse/actions


## Schedule pre configured in 

https://github.com/Hefezopf/stock-analyse/blob/main/.github/workflows/schedule.workflow.yml


## cURL

./curl.sh "INL.XETRA" 1 offline underrated 20

or Example

curl -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.everest-preview+json' "https://api.github.com/repos/Hefezopf/stock-analyse/dispatches" -d '{"event_type": "curl", "client_payload": {"symbols": "INL.XETRA", "percentage": "1", "query": "offline", "rated": "underrated", "stochastic": "20"}'


# Result

Outputs:
- data/values.SYMBOL.txt
- out/index.SYMBOL.html
- out/result.html
- out/out.tar.gz


# REST Call
curl  --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=VOW.XETRA" | jq '.data[].close'
