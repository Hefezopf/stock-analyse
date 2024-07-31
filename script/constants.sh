#!/bin/bash

# For printf "%.2f"
export LC_NUMERIC=en_US.UTF-8

# Tendency
export RISING=RISING
export LEVEL=LEVEL
export FALLING=FALLING

# CSSLink Color
export GREEN=green
export RED=red
export BLACK=black

# Links
COMDIRECT_URL_STOCKS_PREFIX="https://nutzer.comdirect.de/inf/aktien/detail/chart.html?chartType=MOUNTAIN&useFixAverage=false&freeAverage0=95&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1"
export  COMDIRECT_URL_STOCKS_PREFIX_10D="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=10D&ID_NOTATION="
export  COMDIRECT_URL_STOCKS_PREFIX_6M="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=6M&ID_NOTATION="
export  COMDIRECT_URL_STOCKS_PREFIX_5Y="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=5Y&ID_NOTATION="
COMDIRECT_URL_INDEX_PREFIX="https://www.comdirect.de/inf/etfs/detail/uebersicht.html?chartType=MOUNTAIN&useFixAverage=false&freeAverage0=95&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1"
export  COMDIRECT_URL_INDEX_PREFIX_10D="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=10D&ID_NOTATION="
export  COMDIRECT_URL_INDEX_PREFIX_6M="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=6M&ID_NOTATION="
export  COMDIRECT_URL_INDEX_PREFIX_5Y="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=5Y&ID_NOTATION="

# Files
export DATA_DIR="data"
export STATUS_DIR="status"

#export TEMP_DIR=/tmp
export TEMP_DIR=/dev/shm/

export OWN_SYMBOLS_FILE="config/own_symbols.txt"
export TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
export TRANSACTION_COUNT_FILE="config/transaction_count.txt"
export STOCK_SYMBOLS_FILE="config/stock_symbols.txt"
export TRANSACTION_HISTORY_FILE="config/transaction_history.txt"
export OUT_TRANSACTION_HISTORY_HTML_FILE="out/_transaction_history.html"
