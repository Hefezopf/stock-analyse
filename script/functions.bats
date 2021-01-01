#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/functions.sh

# Constants
OUT_RESULT_FILE="temp/_result.html"
DATA_FILE="test/BEI.txt"
TICKER_NAMES_FILE="test/_ticker_names.txt"
SYMBOL=BEI
SYMBOL_NAME="BEIERSDORF AG"

@test "UsageCheckParameter" {
  run UsageCheckParameter 'ADS BEI' 1 offline underrated 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 offline overrated 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 offline all 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'A.DS' 1 offline underrated 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" xxx offline underrated 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 xxxline all 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline xxxunderrated 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline underrated xxx 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline underrated 10 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline overrated 9 xxx "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline underrated 9 31 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]
}

@test "CurlSymbolName" {
  rm -rf "$TICKER_NAMES_FILE"

  function grep() {
    echo "BEI \"BEIERSDORF AG\""
  }
  export -f grep  

  CurlSymbolName "$SYMBOL" "$TICKER_NAMES_FILE" 0
  [ "$symbolName" == 'BEI "BEIERSDORF AG"' ]  

  function grep() {
    echo ""
  }
  export -f grep 

  function curl() {
    echo "null"
  }
  export -f curl 

  CurlSymbolName XXX "$TICKER_NAMES_FILE" 0
   [ "$symbolName" == 'null' ]

  function curl() {
    echo "[{
        "data": [{
            "figi": "BBG000BLNNH6",
            "securityType": "Common Stock",
            "marketSector": "Equity",
            "ticker": "$SYMBOL",
            "name": "$SYMBOL_NAME",
            "uniqueID": "EQ0010080100001000",
            "exchCode": "US",
            "shareClassFIGI": "BBG001S5S399",
            "compositeFIGI": "BBG000BLNNH6",
            "securityType2": "Common Stock",
            "securityDescription": "$SYMBOL",
            "uniqueIDFutOpt": null
        }]
    }]"
  }
  export -f curl 

  function jq() {
    echo "\"BEIERSDORF AG\""
  }
  export -f jq   

  CurlSymbolName "$SYMBOL" "$TICKER_NAMES_FILE" 0
  [ "$symbolName" == '"BEIERSDORF AG"' ]      
}

@test "WriteComdirectUrlAndStoreFileList" {
  rm -rf temp/_result.html
  WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" true green *
  [ "$reportedSymbolFileList" == 'out/BEI.html' ]
}

@test "StochasticOfDays" {
  StochasticOfDays 14 "$DATA_FILE"
  [ "$stochasticQuoteList" == ' , , , , , , , , , , , , , 0, 4, 6, 25, 52, 88, 100, 76, 82, 100, 100, 100, 51, 66, 47, 87, 67, 54, 64, 45, 44, 0, 0, 11, 24, 0, 0, 47, 65, 76, 82, 79, 78, 87, 80, 91, 100, 100, 100, 100, 66, 100, 93, 100, 58, 47, 65, 77, 79, 0, 0, 0, 6, 13, 34, 33, 30, 83, 93, 100, 100, 100, 100, 87, 66, 59, 56, 27, 4, 22, 12, 16, 1, 0, 0, 0, 7, 0, 7, 3, 0, 5, 27, 24, 97, 69, 56,' ]
}

@test "RSIOfDays" {
  RSIOfDays 14 "$DATA_FILE"
  [ "$RSIQuoteList" == ' , , , , , , , , , , , , , 29, 21, 31, 27, 49, 58, 55, 57, 51, 60, 70, 56, 64, 61, 65, 62, 55, 60, 53, 52, 46, 39, 38, 36, 30, 33, 43, 49, 43, 46, 47, 44, 47, 45, 54, 68, 68, 67, 80, 75, 71, 66, 68, 56, 55, 60, 60, 65, 40, 30, 27, 28, 27, 38, 32, 32, 44, 51, 54, 53, 53, 53, 68, 70, 71, 70, 62, 49, 54, 53, 36, 28, 19, 16, 12, 16, 17, 24, 24, 24, 29, 42, 30, 50, 44, 47, 47,' ]
}

@test "AverageOfDays" {
  AverageOfDays 14 "$DATA_FILE"
  [ "$averagePriceList" == ' , , , , , , , , , , , , , 97.6086, 97.1421, 96.5629, 96.1479, 95.6471, 95.6329, 95.7471, 95.8257, 95.9357, 95.9543, 96.0971, 96.3714, 96.4757, 96.7186, 96.9129, 97.22, 97.4757, 97.5757, 97.7629, 97.8329, 97.8714, 97.7957, 97.55, 97.3014, 97.0186, 96.5571, 96.2214, 96.0557, 96.0343, 95.8971, 95.8271, 95.7786, 95.6529, 95.6014, 95.4929, 95.5914, 95.9429, 96.2886, 96.5986, 97.1136, 97.5707, 97.9157, 98.1543, 98.4329, 98.5514, 98.6486, 98.8357, 99.0286, 99.2957, 99.0586, 98.5143, 97.87, 97.2543, 96.6207, 96.2679, 95.7929, 95.3114, 95.1357, 95.1686, 95.3279, 95.455, 95.5693, 95.6693, 96.1264, 96.625, 97.1393, 97.6064, 97.8993, 97.8964, 98.005, 98.1036, 97.8507, 97.4421, 96.8786, 96.2486, 95.5143, 94.8271, 94.2029, 93.7757, 93.3686, 92.9429, 92.6486, 92.5486, 92.33, 92.3443, 92.2586, 92.2214,' ]
}

@test "LesserThenWithFactor" {
  run LesserThenWithFactor 0 99 100
  [ "$status" -eq 1 ]
  #assert_output ''
  [ "$output" == '' ]  

  run LesserThenWithFactor 1 100 99
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LesserThenWithFactor 1 100 100
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LesserThenWithFactor 1 99 100
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run LesserThenWithFactor 1.1 100 111
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run LesserThenWithFactor 1.1 100 109
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LesserThenWithFactor 1.1 100 110
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  
}

@test "GreaterThenWithFactor" {
  run GreaterThenWithFactor 0 99 100
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1 100 99
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1 100 100
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1 101 100
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1.1 100 101
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1.1 100 109
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1.1 100 110
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  
}
