#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/strategies.sh

@test "StrategieUnderrated3LowStochastic" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderrated3LowStochastic 
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic underrated 9 " , 8, 17, 8," "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderrated3LowStochastic" == '' ]

  StrategieUnderrated3LowStochastic underrated 9 " , 0, 0, 0," "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderrated3LowStochastic" == '+ Low stochastic: 3 last stochastic quotes are under 9' ]
}

@test "StrategieUnderratedLowStochasticLowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowStochasticLowRSI 
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 10 5 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 0 91 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 10 91 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '' ]

  StrategieUnderratedLowStochasticLowRSI underrated 9 90 0 5 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowStochasticLowRSI" == '+ Low Stoch & Low RSI: last Stoch quote 0 under 9 and last RSI quote 5 under 90' ]
}

@test "StrategieUnderratedLowRSI" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedLowRSI underrated 10 20 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowRSI" == '' ]

  StrategieUnderratedLowRSI underrated 99 5 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowRSI" == '+ Low RSI: last RSI quote 5 under 99' ]

  StrategieUnderratedLowRSI underrated 10 9 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedLowRSI" == '+ Low RSI: last RSI quote 9 under 10' ]
}

@test "StrategieUnderratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieUnderratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '' ]

  StrategieUnderratedByPercentAndStochastic underrated 0 9 1 1 1 1 1 1 "46.95" "0.99" "49.34" "50.08" "52.87" 9 "temp/_result.html" GIS "GIS Gilead Sciences"
  [ "$resultStrategieUnderratedByPercentAndStochastic" == '+ Underrated by percent and stochastic: 46.95 EUR is 0.99 under Avg18 49.34 EUR and Avg38 50.08 EUR and Avg100 52.87 EUR and Stoch14 0 is lower then 9' ]  
}

@test "StrategieOverratedByPercentAndStoch" {
  function WriteComdirectUrlAndStoreFileList() {
    echo ""
  }
  export -f WriteComdirectUrlAndStoreFileList

  StrategieOverratedByPercentAndStochastic underrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 72 91 1 1 1 1 1 1 "287.50" "1.01" "281.09" "277.85" "272.43" 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '' ]  

  StrategieOverratedByPercentAndStochastic overrated 100 91 1 1 1 1 1 1 "5.61" "1.01" "4.44" "4.28" "4.03" 91 "temp/_result.html" BEI "BEI Beiersdorf AG"
  [ "$resultStrategieOverratedByPercentAndStochastic" == '- Overrated by percent and stochastic: 5.61 EUR is 1.01 over Avg18 4.44 EUR and Avg38 4.28 EUR and Avg100 4.03 EUR and Stoc14 is 100 is higher then 91' ]
}
