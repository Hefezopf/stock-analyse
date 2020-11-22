# stock-analyse
Stock Analyse.

Script wertet die Kurse der letzten 100, 38, 18 Tage aus.

# run
./analyse.sh [offline]

# REST
export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"
curl  --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=VOW.XETRA" | jq '.data[].close'
