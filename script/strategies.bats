#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import
. ./script/constants.sh
. ./script/strategies.sh

# Constants
OUT_RESULT_FILE=temp/_result.html
SYMBOL=BEI
SYMBOL_NAME="BEI BEIERSDORF AG"

@test "StrategieOverratedXHighRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedXHighRSI 
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 72, 72, 72, 73, 74, 76, 77, 76," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 3 last RSI (R): 3 last quotes are over 75' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 98 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 3 last RSI (R): 3 last quotes are over 98' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 75, 75, 76, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes are over 75' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 75, 76, 77, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 5 last RSI (R): 5 last quotes are over 75' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 71, 76, 77, 99, 70, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes are over 75' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 78, 76, 77, 70, 70, 76," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes are over 75' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 78, 76, 77, 70, 70, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]
}

@test "StrategieUnderratedXLowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedXLowRSI 
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 23, 22, 22," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 3 last RSI (R): 3 last quotes are under 25' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 2 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 3 last RSI (R): 3 last quotes are under 2' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 4 last RSI (R): 4 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 5, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 6 last RSI (R): 6 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 5, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 7 last RSI (R): 7 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 9, 9, 8, 0, 0, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 0, 0, 8, 9, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes are under 9' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 0, 0, 8, 9, 9, 9," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]
}

@test "StrategieOverratedXHighStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedXHighStochastic 
  [ "$resultStrategieOverratedXHighStochastic" == '' ]

  StrategieOverratedXHighStochastic 81 " , , 11, 11, 11, 11, 80, 81, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == '' ]

  StrategieOverratedXHighStochastic 81 " , , 11, 11, 11, 83, 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 84, 11, 11, 11, 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 99, 11, 82, 82, 88," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 88, 11, 11, 85, 84, 77, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 86, 85, 84, 83, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 87, 80, 86, 85, 84, 80, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 87, 80, 86, 85, 82, 83, 80," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes are over 81' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 80, 87, 86, 85, 80, 80, 80," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == '' ]
}

@test "StrategieUnderratedXLowStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedXLowStochastic 
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 11, 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 11, 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 0, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 0, 11, 0, 11, 0, 11, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 1, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 1, 1, 1, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 7 last Stochastic (S): 7 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 1, 1, 1, 0, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 6 last Stochastic (S): 6 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 9, 1, 1, 0, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 5 last Stochastic (S): 5 last quotes are under 9' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 9, 1, 9, 0, 0, 9," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes are under 9' ]
}

@test "StrategieByTendency" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieByTendency
  [ "$resultStrategieByTendency" == '' ]

  StrategieByTendency 100 "$RISING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 99 "$RISING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Buy: Low Quote by Tendency (T): 99€ is under Avg95 100€ with Tendency RISING' ]

  resultStrategieByTendency=""
  StrategieByTendency 110 "$RISING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 111 "$RISING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Sell: High Quote by Tendency (T): 111€ is over Avg95 100€ with Tendency RISING' ]

  resultStrategieByTendency=""
  StrategieByTendency 96 "$LEVEL" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Buy: Low Quote by Tendency (T): 96€ is under Avg95 100€ with Tendency LEVEL' ]

  resultStrategieByTendency=""
  StrategieByTendency 98 "$LEVEL" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 100 "$LEVEL" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 103 "$LEVEL" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 104 "$LEVEL" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Sell: High Quote by Tendency (T): 104€ is over Avg95 100€ with Tendency LEVEL' ]

  resultStrategieByTendency=""
  StrategieByTendency 90 "$FALLING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Buy: Low Quote by Tendency (T): 90€ is under Avg95 100€ with Tendency FALLING' ]

  resultStrategieByTendency=""
  StrategieByTendency 91 "$FALLING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 100 "$FALLING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == '' ]

  resultStrategieByTendency=""
  StrategieByTendency 101 "$FALLING" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieByTendency" == 'Sell: High Quote by Tendency (T): 101€ is over Avg95 100€ with Tendency FALLING' ]
}

@test "StrategieOverratedHighHorizontalMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedHighHorizontalMACD 
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , -0.1, 0.2, 0.3, 0.4,
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.1, 0.2, 0.3, 0.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.2, 0.1, 0.2,
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.1, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.2, 0.2, 0.1,
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.2, 0.1," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.2, 0.3, 0.2,
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.3, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.1, 0.2, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.1, 0.2, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD (M): last MACD 0.2' ]

  # , 0.2, 0.2, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.2, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD (M): last MACD 0.2' ]
}

@test "StrategieUnderratedLowHorizontalMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowHorizontalMACD 
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.1, -0.2, -0.3, -0.4,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.1, -0.2, -0.3, -0.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.2, -0.1, -0.2,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.1, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.2, -0.2, -0.1,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.2, -0.1," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.1, -0.2, -0.2,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.1, -0.2, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD (M): last MACD -0.2' ]

#   # , -0.2, -0.2, -0.2,
#   resultStrategieUnderratedLowHorizontalMACD=""
#   StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.2, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
#   [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD (M): last MACD -0.2' ]

  # , -0.2, -0.3, -0.3,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.3, -0.3," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD (M): last MACD -0.3' ]
}

@test "StrategieOverratedHighStochasticHighRSIHighMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedHighStochasticHighRSIHighMACD 
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 90 69 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 69 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 90 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 90 71 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 71 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+ (C): Stochastic quote 92 over 91 and RSI quote 71 over 70' ]

  resultStrategieOverratedHighStochasticHighRSIHighMACD=""
  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+ (C): Stochastic quote 92 over 91 and RSI quote 71 over 70' ]  
}

@test "StrategieUnderratedLowStochasticLowRSILowMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowStochasticLowRSILowMACD 
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 10 5 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 91 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 10 91 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 10 91 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 5 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 5 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == 'Buy: Low Stochastic & RSI & MACD- (C): Stochastic quote 0 under 9 and RSI quote 5 under 90' ]

  resultStrategieUnderratedLowStochasticLowRSILowMACD=""
  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 5 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == 'Buy: Low Stochastic & RSI & MACD- (C): Stochastic quote 0 under 9 and RSI quote 5 under 90' ]
}

@test "StrategieUnderratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedByPercentAndStochastic
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == 'Buy: Low Percentage & Stochastic (P): 46.95€ is 0.99 under Avg18 49.34€ and Avg38 50.08€ and Avg95 52.87€ and Stoch14 0 is lower then 9' ]  

  resultStrategieUnderratedByPercentAndStochastic=""
  StrategieUnderratedByPercentAndStochastic 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == 'Buy: Low Percentage & Stochastic (P): 46.95€ is 0.99 under Avg18 49.34€ and Avg38 50.08€ and Avg95 52.87€ and Stoch14 0 is lower then 9' ]  
}

@test "StrategieOverratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByPercentAndStochastic
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == 'Sell: High Percentage & Stochastic (P): 5.61€ is 1.01 over Avg18 4.44€ and Avg38 4.28€ and Avg95 4.03€ and Stoch14 is 100 is higher then 91' ]

  resultStrategieOverratedByPercentAndStochastic=""
  StrategieOverratedByPercentAndStochastic 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == 'Sell: High Percentage & Stochastic (P): 5.61€ is 1.01 over Avg18 4.44€ and Avg38 4.28€ and Avg95 4.03€ and Stoch14 is 100 is higher then 91' ]
}
