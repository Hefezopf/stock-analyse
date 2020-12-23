#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/strategies.sh

@test "StrategieOverratedByPercentAndStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByPercentAndStochastic overrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" 72 91 "temp/_result.html" BEI
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 100 91 "temp/_result.html" BEI
  [ "$resultStrategieOverratedByPercentAndStochastic" == '- Overrated by percent and stochastic: 5.61 EUR is 1.01 over Avg18 4.44 EUR and Avg38 4.28 EUR and Avg100 4.03 EUR and Stoc14 is 100 is higher then 91' ]
}
