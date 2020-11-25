# Stock Analyse
Automated Stock Analysis.

This script checks given stock quotes and their averages of the last 100, 38, 18 days.


# Run
./analyse.sh SYMBOLS PERCENTAGE [offline]

./analyse-xetra100.sh 9 online 

./analyse-dax30.sh 9 offline 

./analyse.sh 'ADS.XETRA' 9 online 

./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA' 9 offline


# Result

Outputs a result.txt


# REST Call
export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"
curl  --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=VOW.XETRA" | jq '.data[].close'
