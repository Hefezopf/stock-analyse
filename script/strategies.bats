#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/strategies.sh

# Constants
OUT_RESULT_FILE=temp/_result.html
SYMBOL=BEI
SYMBOL_NAME="BEI BEIERSDORF AG"

@test "StrategieOverrated3HighStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverrated3HighStochastic 
  [ "$resultStrategieOverrated3HighStochastic" == '' ]

  StrategieOverrated3HighStochastic underrated 81 " , 80, 81, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == '' ]

  StrategieOverrated3HighStochastic overrated 81 " , 80, 81, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == '' ]

  StrategieOverrated3HighStochastic overrated 81 " , 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == '- High stochastic: 3 last stochastic quotes are over 81' ]

  StrategieOverrated3HighStochastic all 81 " , 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == '- High stochastic: 3 last stochastic quotes are over 81' ]

  StrategieOverrated3HighStochastic overrated 81 " , 82, 82, 88," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == '- High stochastic: 3 last stochastic quotes are over 81' ]
}

@test "StrategieUnderrated3LowStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderrated3LowStochastic 
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic overrated 9 " , 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic underrated 9 " , 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic all 9 " , 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic all 9 " , 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == '+ Low stochastic: 3 last stochastic quotes are under 9' ]

  StrategieUnderrated3LowStochastic underrated 9 " , 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == '+ Low stochastic: 3 last stochastic quotes are under 9' ]
}

@test "StrategieUnderratedLowStochasticLowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowStochasticLowRSI 
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI overrated 9 90 10 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 10 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 0 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 10 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI all 9 90 0 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '+ Low Stoch & Low RSI: last Stoch quote 0 under 9 and last RSI quote 5 under 90' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 0 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '+ Low Stoch & Low RSI: last Stoch quote 0 under 9 and last RSI quote 5 under 90' ]
}

@test "StrategieUnderratedLowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowRSI
  [ "$resultStrategieUnderratedLowRSI" == '' ]

  StrategieUnderratedLowRSI overrated 10 20 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowRSI" == '' ]

  StrategieUnderratedLowRSI underrated 10 20 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowRSI" == '' ]

  StrategieUnderratedLowRSI underrated 99 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowRSI" == '+ Low RSI: last RSI quote 5 under 99' ]

  StrategieUnderratedLowRSI all 99 5 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowRSI" == '+ Low RSI: last RSI quote 5 under 99' ]

  StrategieUnderratedLowRSI underrated 10 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowRSI" == '+ Low RSI: last RSI quote 9 under 10' ]
}

@test "StrategieUnderratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedByPercentAndStochastic
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '+ Underrated by percent and stochastic: 46.95 EUR is 0.99 under Avg18 49.34 EUR and Avg38 50.08 EUR and Avg100 52.87 EUR and Stoch14 0 is lower then 9' ]  

  StrategieUnderratedByPercentAndStochastic all 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '+ Underrated by percent and stochastic: 46.95 EUR is 0.99 under Avg18 49.34 EUR and Avg38 50.08 EUR and Avg100 52.87 EUR and Stoch14 0 is lower then 9' ]  
}

@test "StrategieOverratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByPercentAndStochastic
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic underrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '- Overrated by percent and stochastic: 5.61 EUR is 1.01 over Avg18 4.44 EUR and Avg38 4.28 EUR and Avg100 4.03 EUR and Stoch14 is 100 is higher then 91' ]

  StrategieOverratedByPercentAndStochastic all 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '- Overrated by percent and stochastic: 5.61 EUR is 1.01 over Avg18 4.44 EUR and Avg38 4.28 EUR and Avg100 4.03 EUR and Stoch14 is 100 is higher then 91' ]
}
