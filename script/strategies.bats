#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/strategies.sh

@test "StrategieUnderratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 100 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 100 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 0 9 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '+ Underrated by percent and stochastic: 46.95 EUR is 0.99 under Avg18 49.34 EUR and Avg38 50.08 EUR and Avg100 52.87 EUR and Stoch14 0 is lower then 9' ]  
}

@test "StrategieOverratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByPercentAndStochastic underrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" 72 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" 72 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 100 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '- Overrated by percent and stochastic: 5.61 EUR is 1.01 over Avg18 4.44 EUR and Avg38 4.28 EUR and Avg100 4.03 EUR and Stoc14 is 100 is higher then 91' ]
}
