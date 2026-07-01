#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import
. script/constants.sh
. script/functions.sh

# Constants
#TEMP_DIR=/tmp
TEMP_DIR=/dev/shm/
OUT_RESULT_FILE="test/_result.html"
DATA_FILE="test/BEI.txt"
TICKER_NAMES_FILE="test/ticker_name_id.txt"
SYMBOL=BEI
SYMBOL_NAME="BEIERSDORF"

@test "GetCreationDate" {
  GetCreationDate
  [ "$creationDate" != "" ]
}

@test "DetermineTendency" {
  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 92.6132, 92.5305, 92.4579, 92.3874, 92.3326, 92.3184,"
  [ "$tendency" == $FALLING ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 67.9032, 67.8147, 67.7474, 67.6842, 67.6, 67.5095,"
  [ "$tendency" == $FALLING ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 32.672, 32.7368, 32.7992, 32.8838, 32.9635, 33.053,"
  [ "$tendency" == $RISING ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 45.9983, 46.0558, 46.1133, 46.1728, 46.2373, 46.3183,"
  [ "$tendency" == $RISING ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 6.12202, 6.16208, 6.20124, 6.24516, 6.28693, 6.33078,"
  [ "$tendency" == $RISING ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 7.61869, 7.61285, 7.60964, 7.60801, 7.61092, 7.61816,"
  [ "$tendency" == $LEVEL ]

  DetermineTendency " , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , 9.76287, 9.76511, 9.76757, 9.76948, 9.77083, 9.7742,"
  [ "$tendency" == $LEVEL ]
}

@test "CalculateMarketCapRSILevel" {
  CalculateMarketCapRSILevel 1 "?"
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 16 ?
  [ "$isMarketCapRSILevel" == "true" ]  

  CalculateMarketCapRSILevel 15 ?
  [ "$isMarketCapRSILevel" == "true" ]  

  CalculateMarketCapRSILevel 25 "?"
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 25 1
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 25 100
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 25 101
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 23 70
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 23 69
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 22 60
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 22 59
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 21 50
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 21 49
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 18 18
  [ "$isMarketCapRSILevel" == "false" ]

  CalculateMarketCapRSILevel 18 17
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 17 9
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 16 4
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 15 4
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 1 9
  [ "$isMarketCapRSILevel" == "true" ]

  CalculateMarketCapRSILevel 1 5
  [ "$isMarketCapRSILevel" == "true" ]
}

@test "CalculateTxFee" {
  CalculateTxFee 100 25
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "10" ]

  CalculateTxFee 100 35
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "10" ]
  
  CalculateTxFee 100 51
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "15" ]
   
  CalculateTxFee 100 104
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "20" ]
     
  CalculateTxFee 100 155
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "30" ]
     
  CalculateTxFee 100 400
  [ "$TX_FEE" == "1" ]
#  [ "$TX_FEE" == "47" ]
}

@test "WriteTransactionFile" {
  mkdir -p test/buy
  run WriteTransactionFile "2021-02-09" "$SYMBOL" "test/buy"
  [ "$status" -eq 0 ]
}

@test "WriteAlarmAbbrevXAxisFile" {
  mkdir -p test/alarm
  run WriteAlarmAbbrevXAxisFile "3R+4S+" "$SYMBOL" "test/BEI_2021-02-09.txt" "test/alarm" "*"
  [ "$status" -eq 0 ]
}

@test "UsageCheckParameter" {
  # UsageCheckParameter "$symbolsParam" "$percentageParam" "$stochasticPercentageParam" "$RSIQuoteParam" $OUT_RESULT_FILE
  run UsageCheckParameter 'ADS BEI' 1 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'ADS BEI' 1 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter 'A.DS' 1 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" xxx 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 9 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 0 ]

  run UsageCheckParameter "$SYMBOL" 1 xxx 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 10 30 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 9 xxx "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]

  run UsageCheckParameter "$SYMBOL" 1 9 31 "$OUT_RESULT_FILE"
  [ "$status" -eq 5 ]
}

@test "CurlSymbolName" {
  rm -rf "$TICKER_NAMES_FILE"

  function grep() {
    echo "BEI \"BEIERSDORF\""
  }
  export -f grep  

  CurlSymbolName "$SYMBOL" "$TICKER_NAMES_FILE" 0 "$SYMBOL_NAME"
  [ "$symbolName" == 'BEIERSDORF' ]  

  function grep() {
    echo ""
  }
  export -f grep 

  function curl() {
    echo "null"
  }
  export -f curl 

  CurlSymbolName XXX "$TICKER_NAMES_FILE" 0 "$SYMBOL_NAME"
   [ "$symbolName" == 'BEIERSDORF' ]

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
    echo "\"BEIERSDORF\""
  }
  export -f jq   

  CurlSymbolName "$SYMBOL" "$TICKER_NAMES_FILE" 0 "$SYMBOL_NAME"
  [ "$symbolName" == 'BEIERSDORF' ]
}

@test "LessThenWithFactor" {
  run LessThenWithFactor 0 99 100
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1 100 99
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1 100 100
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1 99 100
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1.1 100 111
  [ "$status" -eq 1 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1.1 100 109
  [ "$status" -eq 0 ]
  [ "$output" == '' ]  

  run LessThenWithFactor 1.1 100 110
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

@test "SymbolsParamShortend" {
  SymbolsParamShortend "*TR4 BSX JEM"
  [ "$SYMBOLS_PARAM_SHORTEND" == '*TR4 BSX JEM' ]

  SymbolsParamShortend "*TR4 *BSX *JEM *COZ *3CP *HLD *VOW3 *BY6 *8TI *BMW *CBHD *Z85 *IU2 *TNE5 *N2S *PZX *AHLA *P2H *1WE *GYC *PFE *OEWA *NJB *DBXT *ISPA *EHDL *ZPRG ADB RCF KWS AUD LSPP EQ6 BEI HXG RLI PRU GRM JUN3 GRU HNR1 2BH CAO MUV2 FRE L10 AZ5 ABL 2M6 NWL NNND 013A 02M 04Q 0B2 0OK 0QF 0R1 0UB 0V6 0VD 0YB0 0ZC 1170 12DA 185 18LB 19V 1AE 1BR1 1COV 1L30 1N8 1NBA 1NN 1PM 1QZ 1SI 1SQ 1SXP 1TY 1U1 1VRA 1YD 1YQA 1ZB 22UA 22Z 25M 2CL 2ED 2FE 2IL 2IS 2KD 2NF 2NN 2OU 2OY 2PP 2R7 2S3 2U3 2VO 2X0 2X1 307 33L 34D 34U 37C 3AD1 3AL 3E2 3EC 3P7 3QD 3RB0 3SM 3UX 3V64 45C 472 485 48CA 48Z 4AB 4BE 4BV 4I1 4PG 4QT1 4S0 4SP 4VK 526 547A 58H 5AP 5BP 5GH 5UR 5VA 5ZM 60A 639 669 68F 6AA0 6BF 6D81 6EQ 6GJ 6MK 6RV 6Z1 76J 7CA 7DB 7EL 7HP 7LB 7PI 7PV 7RM 7UB 7W71 8BU 8CW 8FS 8GC 8IG 8JO 8RJ 8TRA 8WF 8ZQ 8ZU 9301 98P 99U 9MD 9MW 9PDA 9TG A00 A0T A16 A4S A58 A59 A6I AA9 AACA AB2 ABEA ABG ABJ ABR ABS2 ACE1 ACR ACT ADI1 ADM ADP ADS ADV AE4 AEC1 AEND AEP AES AEU AFL AFR0 AFW AFX AG1 AG8 AHOG AI3A AIL AINN AIR AIXA AJ3 AK1 AK3 AKU1"
  [ "$SYMBOLS_PARAM_SHORTEND" == '*TR4 *BSX *JEM *COZ *3CP *HLD *VOW3 *BY6 *8TI *BMW *CBHD *Z85 *IU2 *TNE5 *N2S *PZX *AHLA *P2H *1WE *GYC *PFE *OEWA *NJB *DBXT *ISPA *EHDL *ZPRG ADB RCF KWS AUD LSPP EQ6 BEI HXG RLI PRU GRM JUN3 GRU HN ...' ]
}
