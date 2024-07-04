#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import
. script/constants.sh
. script/strategies.sh

# Constants
OUT_RESULT_FILE=test/_result.html
SYMBOL=BEI
SYMBOL_NAME="BEI BEIERSDORF AG"

function WriteComdirectUrlAndStoreFileList() {
    echo ""
}
export -f WriteComdirectUrlAndStoreFileList

@test "StrategieUnderratedNewLow" {
  StrategieUnderratedNewLow 
  [ "$resultStrategieUnderratedNewLow" == '' ]

  StrategieUnderratedNewLow 3 "25, 24, 26" "26" "24" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
  [ "$resultStrategieUnderratedNewLow" == '' ]

  StrategieUnderratedNewLow 5 "59.36, 58.4, 58.86, 58.92, 58.58, 59.12, 59.28, 58.96, 57.98, 58.66, 60.1, 60.12, 60.94, 61.82, 59.96, 61.42, 62.48, 62.28, 61.1, 61.26, 61.02, 59.88, 59.6, 60.2, 59.14, 57.28, 56.96, 57.68, 58.7, 55.42, 54.2, 53.7, 54.12, 54.14, 56.36, 56.44, 58.2, 57.34, 57.3, 58.26, 57.12, 55.76, 55.88, 56.42, 57.52, 57.9, 56.76, 58.5, 55.78, 54.82, 55.76, 54.56, 55.14, 56.3, 55.78, 55.72, 54.96, 54.42, 55.86, 54.98, 58, 58.8, 58.02, 58.66, 57.56, 57.54, 57.44, 56.36, 55.88, 56.34, 55.34, 56.58, 55.86, 55.98, 55.72, 56.9, 57.3, 57.3, 58.28, 57.48, 57.82, 54.10, 57.98, 56.54, 54.68, 54.24, 54.11," "54.11" "54.24" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
  [ "$resultStrategieUnderratedNewLow" == '' ]

  resultStrategieUnderratedNewLow=""
  StrategieUnderratedNewLow 3 "59.36, 58.4, 58.86, 58.92, 58.58, 59.12, 59.28, 58.96, 57.98, 58.66, 60.1, 60.12, 60.94, 61.82, 59.96, 61.42, 62.48, 62.28, 61.1, 61.26, 61.02, 59.88, 59.6, 60.2, 59.14, 57.28, 56.96, 57.68, 58.7, 55.42, 54.2, 53.7, 54.12, 54.14, 56.36, 56.44, 58.2, 57.34, 57.3, 58.26, 57.12, 55.76, 55.88, 56.42, 57.52, 57.9, 56.76, 58.5, 55.78, 54.82, 55.76, 54.56, 55.14, 56.3, 55.78, 55.72, 54.96, 54.42, 55.86, 54.98, 58, 58.8, 58.02, 58.66, 57.56, 57.54, 57.44, 56.36, 55.88, 56.34, 55.34, 56.58, 55.86, 55.98, 55.72, 56.9, 57.3, 57.3, 58.28, 57.48, 57.82, 58.16, 57.98, 56.54, 54.68, 54.24, 54.11," "54.11" "54.24" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
  [ "$resultStrategieUnderratedNewLow" == 'Buy: New 3 days Low (N)' ]

  resultStrategieUnderratedNewLow=""
  StrategieUnderratedNewLow 5 "59.36, 58.4, 58.86, 58.92, 58.58, 59.12, 59.28, 58.96, 57.98, 58.66, 60.1, 60.12, 60.94, 61.82, 59.96, 61.42, 62.48, 62.28, 61.1, 61.26, 61.02, 59.88, 59.6, 60.2, 59.14, 57.28, 56.96, 57.68, 58.7, 55.42, 54.2, 53.7, 54.12, 54.14, 56.36, 56.44, 58.2, 57.34, 57.3, 58.26, 57.12, 55.76, 55.88, 56.42, 57.52, 57.9, 56.76, 58.5, 55.78, 54.82, 55.76, 54.56, 55.14, 56.3, 55.78, 55.72, 54.96, 54.42, 55.86, 54.98, 58, 58.8, 58.02, 58.66, 57.56, 57.54, 57.44, 56.36, 55.88, 56.34, 55.34, 56.58, 55.86, 55.98, 55.72, 56.9, 57.3, 57.3, 58.28, 57.48, 57.82, 54.12, 57.98, 56.54, 54.68, 54.24, 54.11," "54.11" "54.24" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
  [ "$resultStrategieUnderratedNewLow" == 'Buy: New 5 days Low (N)' ]
}

@test "StrategieUnderratedLowHorizontalMACD" {
  StrategieUnderratedLowHorizontalMACD 
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # ----------x------------
  # --------x---x----------
  # ------x----------------
  # -----------------------
  # , -8.3, -8.2, -8.1, -8.2,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -8.3, -8.2, -8.1, -8.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # -----------------------
  # --------x---x----------
  # ------x---x------------
  # -----------------------  
  # , -8.3, -8.2, -8.3, -8.2,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -8.3, -8.2, -8.3, -8.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # --x--------------------
  # ----x------------------
  # ------x----------------
  # --------x--------------
  # , 8.1, 8.2, 8.3, 0.01, NOT NEGATIV -> NO ALERT!
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , 1.189, 0.879, 0.825, 0.933, 0.488, 0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, 1.609, 3.193, 4.597, 6.243, 7.342, 8.398, 9.29, 9.643, 9.331, 8.502, 7.556, 6.689, 5.734, 5.239, 5.51, 5.899, 6.256, 6.305, 6.232, 6.263, 6.056, 5.825, 5.618, 5.551, 5.874, 6.379, 6.183, 6.079, 5.888, 5.792, 5.81, 5.877, 7.865, 8.615, 8.658, 9.662, 8.1, 8.2, 8.3, 0.01," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # --x--------------------
  # ----x------------------
  # ------x----------------
  # --------x--------------
  # , 0.1, -0.2, -0.3, -0.4, NOT LAST 4 NEGATIV -> NO ALERT!
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , 1.189, 0.879, 0.825, 0.933, 0.488, 0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, 1.609, 3.193, 4.597, 6.243, 7.342, 8.398, 9.29, 9.643, 9.331, 8.502, 7.556, 6.689, 5.734, 5.239, 5.51, 5.899, 6.256, 6.305, 6.232, 6.263, 6.056, 5.825, 5.618, 5.551, 5.874, 6.379, 6.183, 6.079, 5.888, 5.792, 5.81, 5.877, 7.865, 8.615, 8.658, 9.662, 0.1, -0.2, -0.3, -0.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # --x--------------------
  # ----x------------------
  # ------x----------------
  # --------x--------------
  # , 8.1, 8.2, 8.3, -0.01, NOT LAST 4 NEGATIV -> NO ALERT!
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , 1.189, 0.879, 0.825, 0.933, 0.488, 0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, 1.609, 3.193, 4.597, 6.243, 7.342, 8.398, 9.29, 9.643, 9.331, 8.502, 7.556, 6.689, 5.734, 5.239, 5.51, 5.899, 6.256, 6.305, 6.232, 6.263, 6.056, 5.825, 5.618, 5.551, 5.874, 6.379, 6.183, 6.079, 5.888, 5.792, 5.81, 5.877, 7.865, 8.615, 8.658, 9.662, 8.1, 8.2, 8.3, -0.01," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # ----x-----x------------
  # ------x-x--------------
  # -----------------------
  # -----------------------  
  # , -10.1, -10.2, -10.2, -10.0, HAS TURNED, TOO LATE FOR ALERT -> NO ALERT!
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.1, -10.2, -10.2, -10.0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == '' ]

  # --x--------------------
  # ----x------------------
  # ------x----------------
  # --------x--------------
  # , -18.1, -18.2, -18.3, -18.4,
  resultStrategieUnderratedLowHorizontalMACD=""  
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -18.1, -18.2, -18.3, -18.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -18.4' ]

  # ----x------------------
  # ------x-x-x------------
  # -----------------------
  # ----------------------- 
  # , -10.1, -10.2, -10.2, -10.2, 
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.1, -10.2, -10.2, -10.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -10.2' ]

  # ----x------------------
  # ------x----------------
  # --------x-x------------
  # ----------------------- 
  # , -10.1, -10.2, -10.3, -10.3,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.1, -10.2, -10.3, -10.3," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -10.3' ]

  # ----x------------------
  # ------x----------------
  # --------x-x------------
  # ----------------------- 
  # , -10.1, -20.2, -30.3, -30.3,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.1, -20.2, -30.3, -30.3," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -30.3' ]

  # ----x------------------
  # ------x----------------
  # --------x-x------------
  # ----------------------- 
  # , -10.1, -30.2, -60.3, -60.3,
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.1, -30.2, -60.3, -60.3," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -60.3' ]

  # -----------------------
  # ------x-x--------------
  # ----x------------------
  # ----------x------------  
  # , -10.3, -10.2, -10.2, -10.4, # NEW LOW
  resultStrategieUnderratedLowHorizontalMACD=""
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , -0.189, -0.879, -0.825, -0.933, -0.488, -0.174, 0.031, 0.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 0.537, 0.01, 0.663, 0.834, 0.969, 0.916, 0.756, 0.434, 0.028, 0.762, 0.085, 0.87, 0.874, 0.491, 0.528, 0.138, 0.32, 0.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -10.3, -10.2, -10.2, -10.4," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -10.4' ]

  # ----x----------------
  # ------x---x----------
  # --------x------------
  # ------------x-------- 
  # , -0.1, -0.2, -0.3, -0.2, -0.4,
  StrategieUnderratedLowHorizontalMACD " , , , , , , , , , , , , 0.68,0.68,0.61,0.56,0.53,0.50,0.44,0.34,0.26,0.17,0.17,0.11,0.07,0.02,-0.08,-0.14,-0.17,-0.23,-0.23,-0.25,-0.37,-0.50,-0.59,-0.68,-0.71,-0.82,-0.87,-0.91,-0.94,-0.94,-0.92,-0.83,-0.75,-0.61,-0.49,-0.38,-0.18,-0.07,0.04,0.13,0.21,0.29,0.33,0.28,0.20,0.16,0.21,0.25,0.24,0.24,0.11,0.02,-0.05,-0.09,-0.02,0.14,0.16,0.14,0.11,0.05,-0.01,-0.04,-0.06,-0.05,-0.02,-0.09,-0.12,-0.24,-0.36,-0.47,-0.59,-0.68,-0.76,-0.79,-0.80," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *                                         
  [ "$resultStrategieUnderratedLowHorizontalMACD" == 'Buy: Low MACD (M): last MACD -0.80' ]  
}

@test "StrategieOverratedHighHorizontalMACD" {
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
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High MACD (M): last MACD 0.2' ]

  # , 0.2, 0.2, 0.2,
  resultStrategieOverratedHighHorizontalMACD=""
  StrategieOverratedHighHorizontalMACD " , , , , , , , , , , , , -1.189, -0.879, -0.825, -0.933, -0.488, -0.174, 1.031, 1.964, 2.592, 2.815, 3.437, 4.084, 4.744, 5.167, 5.838, 6.537, 7.01, 6.663, 6.834, 6.969, 6.916, 6.756, 6.434, 6.028, 5.762, 6.085, 5.87, 5.874, 5.491, 5.528, 4.138, 3.32, 1.724, 0.892, 0.589, -1.609, -3.193, -4.597, -6.243, -7.342, -8.398, -9.29, -9.643, -9.331, -8.502, -7.556, -6.689, -5.734, -5.239, -5.51, -5.899, -6.256, -6.305, -6.232, -6.263, -6.056, -5.825, -5.618, -5.551, -5.874, -6.379, -6.183, -6.079, -5.888, -5.792, -5.81, -5.877, -7.865, -8.615, -8.658, -9.662, -9.62, 0.2, 0.2, 0.2," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighHorizontalMACD" == 'Sell: High MACD (M): last MACD 0.2' ]
}

@test "StrategieOverratedDivergenceRSI" {
  StrategieOverratedDivergenceRSI 
  [ "$resultStrategieOverratedDivergenceRSI" == '' ]

  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "0" "101" "100" "80" "79"
  [ "$resultStrategieOverratedDivergenceRSI" == '' ]
  
  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "1" "100" "100" "80" "81"
  [ "$resultStrategieOverratedDivergenceRSI" == '' ]

  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "101" "100" "80" "81"
  [ "$resultStrategieOverratedDivergenceRSI" == '' ]

  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "1" "101" "100" "70" "71"
  [ "$resultStrategieOverratedDivergenceRSI" == '' ]

  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "1" "101" "100" "80" "81"
  [ "$resultStrategieOverratedDivergenceRSI" == 'Sell: RSI Divergence (D)' ]

  resultStrategieOverratedDivergenceRSI=""
  StrategieOverratedDivergenceRSI 75 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "1" "101" "100" "81" "81"
  [ "$resultStrategieOverratedDivergenceRSI" == 'Sell: RSI Divergence (D)' ]
}

@test "StrategieUnderratedDivergenceRSI" {
  StrategieUnderratedDivergenceRSI 
  [ "$resultStrategieUnderratedDivergenceRSI" == '' ]

  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "0" "99" "100" "20" "100" "false"
  [ "$resultStrategieUnderratedDivergenceRSI" == '' ]
  
  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "100" "100" "20" "100" "true"
  [ "$resultStrategieUnderratedDivergenceRSI" == '' ]

  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "99" "100" "20" "25" "true"
  [ "$resultStrategieUnderratedDivergenceRSI" == '' ]

  resultStrategieUnderratedDivergenceRSI=""
  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "99" "100" "20" "1" "false"
  [ "$resultStrategieUnderratedDivergenceRSI" == '' ]

  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "99" "100" "30" "25" "true"
  [ "$resultStrategieUnderratedDivergenceRSI" == 'Buy: RSI Divergence (D)' ]

  StrategieUnderratedDivergenceRSI 25 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*" "-1" "99" "100" "20" "1" "true"
  [ "$resultStrategieUnderratedDivergenceRSI" == 'Buy: RSI Divergence (D)' ]
}

@test "StrategieOverratedXHighRSI" {
  StrategieOverratedXHighRSI 
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]

  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 72, 72, 72, 73, 74, 76, 77, 76," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 3 last RSI (R): 3 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 98 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 3 last RSI (R): 3 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 75, 75, 76, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 75, 76, 77, 99, 100, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 5 last RSI (R): 5 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 71, 76, 77, 99, 70, 99," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 78, 76, 77, 70, 70, 76," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == 'Sell: High 4 last RSI (R): 4 last quotes over level' ]

  resultStrategieOverratedXHighRSI=""
  StrategieOverratedXHighRSI 75 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 75, 78, 76, 77, 70, 70, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighRSI" == '' ]
}

@test "StrategieUnderratedXLowRSI" {
  StrategieUnderratedXLowRSI 
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 62, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 71, 22, 62," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]

  StrategieUnderratedXLowRSI 25 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 23, 22, 22," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 3 last RSI (R): 3 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 2 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 74, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 3 last RSI (R): 3 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 80, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 4 last RSI (R): 4 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 79, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 72, 5, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 6 last RSI (R): 6 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 5, 8, 8, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 7 last RSI (R): 7 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 9, 9, 8, 0, 0, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 0, 0, 8, 9, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == 'Buy: Low 5 last RSI (R): 5 last quotes under level' ]

  resultStrategieUnderratedXLowRSI=""
  StrategieUnderratedXLowRSI 9 " 29, 25, 23, 27, 33, 29, 33, 31, 31, 33, 40, 30, 40, 44, 40, 44, 52, 44, 41, 48, 43, 47, 54, 56, 41, 45, 28, 34, 35, 49, 45, 49, 44, 42, 63, 66, 65, 58, 65, 72, 76, 75, 68, 63, 68, 74, 75, 76, 64, 56, 56, 63, 63, 61, 58, 61, 70, 74, 66, 51, 52, 59, 62, 67, 58, 56, 58, 48, 49, 42, 39, 43, 53, 60, 64, 62, 69, 74, 88, 77, 2, 0, 0, 8, 9, 9, 9," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowRSI" == '' ]
}

@test "StrategieOverratedXHighStochastic" {
  StrategieOverratedXHighStochastic 
  [ "$resultStrategieOverratedXHighStochastic" == '' ]

  StrategieOverratedXHighStochastic 81 " , , 11, 11, 11, 11, 80, 81, 70," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == '' ]

  StrategieOverratedXHighStochastic 81 " , , 11, 11, 11, 83, 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 84, 11, 11, 11, 100, 82, 100," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 99, 11, 82, 82, 88," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 88, 11, 11, 85, 84, 77, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 4 last Stochastic (S): 4 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 86, 85, 84, 83, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 87, 80, 86, 85, 84, 80, 82," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 87, 80, 86, 85, 82, 83, 80," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == 'Sell: High 5 last Stochastic (S): 5 last quotes over level' ]

  resultStrategieOverratedXHighStochastic=""
  StrategieOverratedXHighStochastic 81 " , , 11, 11, 80, 87, 86, 85, 80, 80, 80," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedXHighStochastic" == '' ]
}

@test "StrategieUnderratedXLowStochastic" {
  StrategieUnderratedXLowStochastic 
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 11, 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 11, 8, 17, 8," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == '' ]

  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 0, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 0, 11, 0, 11, 0, 11, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 11, 11, 11, 1, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 1, 1, 1, 0, 0, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 7 last Stochastic (S): 7 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 1, 1, 1, 0, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 6 last Stochastic (S): 6 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 9, 1, 1, 0, 9, 0," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 5 last Stochastic (S): 5 last quotes under level' ]

  resultStrategieUnderratedXLowStochastic=""
  StrategieUnderratedXLowStochastic 9 " , , 1, 9, 1, 9, 0, 0, 9," "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedXLowStochastic" == 'Buy: Low 4 last Stochastic (S): 4 last quotes under level' ]
}

@test "StrategieByTendency" {
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

@test "StrategieOverratedHighStochasticHighRSIHighMACD" {
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

  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 71 "0" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+ (C): Stochastic 92 over level and RSI 71 over level' ]

  resultStrategieOverratedHighStochasticHighRSIHighMACD=""
  StrategieOverratedHighStochasticHighRSIHighMACD 91 70 92 71 "0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedHighStochasticHighRSIHighMACD" == 'Sell: High Stochastic & RSI & MACD+ (C): Stochastic 92 over level and RSI 71 over level' ]  
}

@test "StrategieUnderratedLowStochasticLowRSILowMACD" {
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

  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 5 "0" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == '' ]

  resultStrategieUnderratedLowStochasticLowRSILowMACD=""
  StrategieUnderratedLowStochasticLowRSILowMACD 9 90 0 5 "-0.1" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedLowStochasticLowRSILowMACD" == 'Buy: Low Stochastic & RSI & MACD- (C): Stochastic 0 under level and RSI 5 under level' ]
}

@test "StrategieUnderratedByPercentAndStoch" {
  StrategieUnderratedByPercentAndStochastic
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic 100 91 1 1 1 1 1 1 "5.61" "1.01" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic 0 9 1 1 1 1 0 1 "46.95" "0.99" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]  

  resultStrategieUnderratedByPercentAndStochastic=""
  StrategieUnderratedByPercentAndStochastic 0 9 1 1 1 1 1 1 "46.95" "0.99" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieUnderratedByPercentAndStochastic" == 'Buy: Low Percent & Stochastic (P): 46.95€ is 0.99 under Avg18 < Avg38 < Avg95 and Stoch14 0 under level' ]  
}

@test "StrategieOverratedByPercentAndStoch" {
  StrategieOverratedByPercentAndStochastic
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic 72 91 1 1 1 1 1 1 "287.50" "1.01" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic 100 91 1 1 1 1 1 0 "5.61" "1.01" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]

  resultStrategieOverratedByPercentAndStochastic=""
  StrategieOverratedByPercentAndStochastic 100 91 1 1 1 1 1 1 "5.61" "1.01" "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" *
  [ "$resultStrategieOverratedByPercentAndStochastic" == 'Sell: High Percent & Stochastic (P): 5.61€ is 1.01 over Avg18 > Avg38 > Avg95 and Stoch14 100 over level' ]
}

@test "StrategieOverratedStochasticWhenOwn" {
  StrategieOverratedStochasticWhenOwn 
  [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  StrategieOverratedStochasticWhenOwn 91 90 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" ""
    [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  StrategieOverratedStochasticWhenOwn 91 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
    [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  StrategieOverratedStochasticWhenOwn 91 92 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" ""
    [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  # Own Stocks
  StrategieOverratedStochasticWhenOwn 91 90 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
    [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  StrategieOverratedStochasticWhenOwn 91 91 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
    [ "$resultStrategieOverratedStochasticWhenOwn" == '' ]

  StrategieOverratedStochasticWhenOwn 91 92 "$OUT_RESULT_FILE" "$SYMBOL" "$SYMBOL_NAME" "*"
    [ "$resultStrategieOverratedStochasticWhenOwn" == 'Sell: Stochastic Own (O)' ]
}
