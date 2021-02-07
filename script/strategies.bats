#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import
. ./script/strategies.sh

# Constants
OUT_RESULT_FILE=temp/_result.html
SYMBOL=BEI
SYMBOL_NAME="BEI BEIERSDORF AG"

@test "StrategieOverratedByTendency" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByTendency
  [ "$resultStrategieOverratedByTendency" == '' ]

  StrategieOverratedByTendency 101 "rising" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == '' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 110 "rising" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == 'Sell: High Quote by Tendency: 110€ is over Avg100 100€ with Tendency rising' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 100 "level" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == '' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 102 "level" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == '' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 103 "level" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == 'Sell: High Quote by Tendency: 103€ is over Avg100 100€ with Tendency level' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 99 "falling" 1 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == '' ]

  resultStrategieOverratedByTendency=""
  StrategieOverratedByTendency 101 "falling" 1 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByTendency" == 'Sell: High Quote by Tendency: 101€ is over Avg100 100€ with Tendency falling' ]
}

@test "StrategieUnderratedByTendency" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedByTendency
  [ "$resultStrategieUnderratedByTendency" == '' ]

  StrategieUnderratedByTendency 99 "falling" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == '' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 95 "falling" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == 'Buy: Low Quote by Tendency: 95€ is under Avg100 100€ with Tendency falling' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 97 "falling" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == '' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 100 "level" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == '' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 97 "level" "1.01" 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == 'Buy: Low Quote by Tendency: 97€ is under Avg100 100€ with Tendency level' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 100 "rising" 1 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == '' ]

  resultStrategieUnderratedByTendency=""
  StrategieUnderratedByTendency 99 "rising" 1 100 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByTendency" == 'Buy: Low Quote by Tendency: 99€ is under Avg100 100€ with Tendency rising' ]
}

@test "StrategieOverrated3HighRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverrated3HighRSI 
  [ "$resultStrategieOverrated3HighRSI" == '' ]

  StrategieOverrated3HighRSI underrated 75 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighRSI" == '' ]

  StrategieOverrated3HighRSI overrated 75 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighRSI" == '' ]

  StrategieOverrated3HighRSI all 75 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighRSI" == '' ]

  StrategieOverrated3HighRSI all 75 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 76, 77, 76," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighRSI" == 'Sell: High 3 last RSI: 3 last quotes are over 75' ]

  resultStrategieOverrated3HighRSI=""
  StrategieOverrated3HighRSI overrated 98 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighRSI" == 'Sell: High 3 last RSI: 3 last quotes are over 98' ]
}

@test "StrategieUnderrated3LowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderrated3LowRSI 
  [ "$resultStrategieUnderrated3LowRSI" == '' ]

  StrategieUnderrated3LowRSI overrated 25 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowRSI" == '' ]

  StrategieUnderrated3LowRSI underrated 25 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowRSI" == '' ]

  StrategieUnderrated3LowRSI all 25 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowRSI" == '' ]

  StrategieUnderrated3LowRSI all 25 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 23, 22, 22," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowRSI" == 'Buy: Low 3 last RSI: 3 last quotes are under 25' ]

  resultStrategieUnderrated3LowStochastic=""
  StrategieUnderrated3LowRSI underrated 2 " , , , , , , , , , , , , , 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowRSI" == 'Buy: Low 3 last RSI: 3 last quotes are under 2' ]
}

@test "StrategieOverratedHighHorizontalMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedHighHorizontalMACD 
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.2, 0.3, 0.2, underrated
  StrategieOverratedHighHorizontalMACD underrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.3, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , -0.1, 0.2, 0.3, 0.4,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD overrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.1, 0.2, 0.3, 0.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.2, 0.1, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD overrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.1, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == '' ]

  # , 0.1, 0.2, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.1, 0.2, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD: last MACD 0.2' ]

  # , 0.2, 0.2, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.2, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD: last MACD 0.2' ]

  # , 0.2, 0.2, 0.1,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.2, 0.1," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD: last MACD 0.1' ]

  # , 0.2, 0.3, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.3, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High horizontal MACD: last MACD 0.2' ]
}

@test "StrategieUnderratedLowHorizontalMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowHorizontalMACD 
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.2, -0.3, -0.2, overrated
  StrategieUnderratedLowHorizontalMACD overrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.3, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.1, -0.2, -0.3, -0.4,
  StrategieUnderratedLowHorizontalMACD underrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.1, -0.2, -0.3, -0.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.2, -0.1, -0.2,
  StrategieUnderratedLowHorizontalMACD underrated " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.1, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # , -0.1, -0.2, -0.2,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.1, -0.2, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD: last MACD -0.2' ]

  # , -0.2, -0.2, -0.2,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.2, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD: last MACD -0.2' ]

  # , -0.2, -0.2, -0.1,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.2, -0.1," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD: last MACD -0.1' ]

  # , -0.2, -0.3, -0.2,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, -0.2, -0.3, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD: last MACD -0.2' ]

  # , -0.2, -0.3, -0.2, -0.1,
#   resultStrategieUnderratedLowHorizontalMACD=""
#   StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.2, -0.3, -0.2, -0.1," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
#   [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD' ]

  # , -0.2, -0.3, -0.2, -0.2,
#   resultStrategieUnderratedLowHorizontalMACD=""
#   StrategieUnderratedLowHorizontalMACD all " , , , , , , , , , , , , , , , , , , , , , , , , ,  -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -0.2, -0.3, -0.2, -0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
#   [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low horizontal MACD' ]
}

@test "StrategieOverratedHighStochasticHighRSIHighMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedHighStochasticHighRSIHighMACD 
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD underrated 91 70 92 71 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD overrated 91 70 90 69 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD overrated 91 70 92 69 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD overrated 91 70 90 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD overrated 91 70 90 71 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD all 91 70 92 71 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == '' ]

  StrategieOverratedHighStochasticHighRSIHighMACD all 91 70 92 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+: Stochastic quote 92 over 91 and RSI quote 71 over 70' ]

  resultStrategieOverratedHighStochasticHighRSIHighMACD=""
  StrategieOverratedHighStochasticHighRSIHighMACD overrated 91 70 92 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+: Stochastic quote 92 over 91 and RSI quote 71 over 70' ]  
}

@test "StrategieUnderratedLowStochasticLowRSILowMACD" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowStochasticLowRSILowMACD 
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD overrated 9 90 10 5 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD underrated 9 90 10 5 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD underrated 9 90 0 91 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD underrated 9 90 10 91 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD underrated 9 90 10 91 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD all 9 90 0 5 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  StrategieUnderratedLowStochasticLowRSILowMACD all 9 90 0 5 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == 'Buy: Low Stochastic & RSI & MACD-: Stochastic quote 0 under 9 and RSI quote 5 under 90' ]

  resultStrategieUnderratedLowStochasticLowRSILowMACD=""
  StrategieUnderratedLowStochasticLowRSILowMACD underrated 9 90 0 5 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == 'Buy: Low Stochastic & RSI & MACD-: Stochastic quote 0 under 9 and RSI quote 5 under 90' ]
}

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
  [ "$resultStrategieOverrated3HighStochastic" == 'Sell: High 3 last Stochastic: 3 last quotes are over 81' ]

  resultStrategieOverrated3HighStochastic=""
  StrategieOverrated3HighStochastic all 81 " , 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == 'Sell: High 3 last Stochastic: 3 last quotes are over 81' ]

  resultStrategieOverrated3HighStochastic=""
  StrategieOverrated3HighStochastic overrated 81 " , 82, 82, 88," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverrated3HighStochastic" == 'Sell: High 3 last Stochastic: 3 last quotes are over 81' ]
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
  [ "$resultStrategieUnderrated3LowStochastic" == 'Buy: Low 3 last Stochastic: 3 last quotes are under 9' ]

  resultStrategieUnderrated3LowStochastic=""
  StrategieUnderrated3LowStochastic underrated 9 " , 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderrated3LowStochastic" == 'Buy: Low 3 last Stochastic: 3 last quotes are under 9' ]
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
  [ "$resultStrategieUnderratedByPercentAndStochastic" == 'Buy: Low Percentage & Stochastic: 46.95€ is 0.99 under Avg18 49.34€ and Avg38 50.08€ and Avg100 52.87€ and Stoch14 0 is lower then 9' ]  

  resultStrategieUnderratedByPercentAndStochastic=""
  StrategieUnderratedByPercentAndStochastic all 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == 'Buy: Low Percentage & Stochastic: 46.95€ is 0.99 under Avg18 49.34€ and Avg38 50.08€ and Avg100 52.87€ and Stoch14 0 is lower then 9' ]  
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
  [ "$resultStrategieOverratedByPercentAndStochastic" == 'Sell: High Percentage & Stochastic: 5.61€ is 1.01 over Avg18 4.44€ and Avg38 4.28€ and Avg100 4.03€ and Stoch14 is 100 is higher then 91' ]

  resultStrategieOverratedByPercentAndStochastic=""
  StrategieOverratedByPercentAndStochastic all 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == 'Sell: High Percentage & Stochastic: 5.61€ is 1.01 over Avg18 4.44€ and Avg38 4.28€ and Avg100 4.03€ and Stoch14 is 100 is higher then 91' ]
}
