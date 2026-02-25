#!/bin/bash

# For uname
export UNAME_N; UNAME_N="$(uname -n)" #runnervmwffz4 (GitHub), markus-ideacentre-700-25ISH (bash Mint) or Laptop-Markus (bash Win)
export UNAME_N_MARKUS_IDEACENTRE_700_25ISH_BASH_MINT="markus-ideacentre-700-25ISH"
export UNAME_N_LAPTOP_MARKUS_BASH_WIN="Laptop-Markus" 
export UNAME_N_ARKUS_BASH_ALL_OS="arkus"

export UNAME_O; UNAME_O="$(uname -o)"
export UNAME_O_GNU_LINUX="GNU/Linux"


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
export COMDIRECT_URL_STOCKS_PREFIX_10D="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=10D&ID_NOTATION="
export COMDIRECT_URL_STOCKS_PREFIX_6M="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=6M&ID_NOTATION="
export COMDIRECT_URL_STOCKS_PREFIX_5Y="$COMDIRECT_URL_STOCKS_PREFIX""&timeSpan=5Y&ID_NOTATION="
COMDIRECT_URL_INDEX_PREFIX="https://www.comdirect.de/inf/etfs/detail/uebersicht.html?chartType=MOUNTAIN&useFixAverage=false&freeAverage0=95&freeAverage1=38&freeAverage2=18&indicatorsBelowChart=SST&indicatorsBelowChart=RSI&indicatorsBelowChart=MACD&PRESET=1"
export COMDIRECT_URL_INDEX_PREFIX_10D="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=10D&ID_NOTATION="
export COMDIRECT_URL_INDEX_PREFIX_6M="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=6M&ID_NOTATION="
export COMDIRECT_URL_INDEX_PREFIX_5Y="$COMDIRECT_URL_INDEX_PREFIX""&timeSpan=5Y&ID_NOTATION="

# Dirs
export DATA_DIR="data"
export STATUS_DIR="status"
export TEMP_DIR="/dev/shm/"

# Files
export COOKIES_FILE="$TEMP_DIR""cookies.txt"
export OWN_SYMBOLS_FILE="config/own_symbols.txt"
export TICKER_NAME_ID_FILE="config/ticker_name_id.txt"
export TICKER_NAME_ID_FILE_MEM="$TEMP_DIR""config/ticker_name_id.txt" #mem
export TRANSACTION_COUNT_FILE="config/transaction_count.txt"
export STOCK_SYMBOLS_FILE="config/stock_symbols.txt"
export TRANSACTION_HISTORY_FILE="config/transaction_history.txt"
export OUT_RESULT_FILE="out/_result.html"
export OUT_TRANSACTION_HISTORY_HTML_FILE="out/_transaction_history.html"
export SCRIPT_START_ALL_IN_CHROME_FILE="script/start-all-in-chrome.sh"
export SIM_LAST_ALARMS_HTML_FILE="simulate/out/_simulate_last_alarms.html"
