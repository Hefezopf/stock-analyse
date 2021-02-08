#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import
. ./script/functions.sh

# Constants
OUT_RESULT_FILE="test/_result.html"
DATA_FILE="test/BEI.txt"
TICKER_NAMES_FILE="test/_ticker_id_names.txt"
SYMBOL=BEI
SYMBOL_NAME="BEIERSDORF AG"

@test "DetermineTendency" {
  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 92.6132, 92.5305, 92.4579, 92.3874, 92.3326, 92.3184,"
  [ "$tendency" == 'falling' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 67.9032, 67.8147, 67.7474, 67.6842, 67.6, 67.5095,"
  [ "$tendency" == 'falling' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 32.672, 32.7368, 32.7992, 32.8838, 32.9635, 33.053,"
  [ "$tendency" == 'rising' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 45.9983, 46.0558, 46.1133, 46.1728, 46.2373, 46.3183,"
  [ "$tendency" == 'rising' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 6.12202, 6.16208, 6.20124, 6.24516, 6.28693, 6.33078,"
  [ "$tendency" == 'rising' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 7.61869, 7.61285, 7.60964, 7.60801, 7.61092, 7.61816,"
  [ "$tendency" == 'level' ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 9.76287, 9.76511, 9.76757, 9.76948, 9.77083, 9.7742,"
  [ "$tendency" == 'level' ]
}

@test "UsageCheckParameter" {
  run UsageCheckParameter 'ADS BEI' 1 offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'A.DS' 1 offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" xxx offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 xxxline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter "$SYMBOL" 1 offline xxx 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline 10 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline 9 xxx "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 offline 9 31 "$OUT_RESULT_FILE"
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
  WriteComdirectUrlAndStoreFileList "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" green *
  [ "$reportedSymbolFileList" == 'out/BEI.html' ]
}

@test "LesserThenWithFactor" {
  run LesserThenWithFactor 0 99 100
  [ "$status" -eq 1 ]
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

  run GreaterThenWithFactor 1 100.0 100.0
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run GreaterThenWithFactor 1 100.1 100.0
  [ "$status" -eq 1 ]
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
