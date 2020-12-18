#!/usr/bin/env bats

# https://github.com/bats-core/bats-core

load '/d/code/bats-assert/load.bash'

# Import functions
. ./script/functions.sh

@test "LesserThenWithFactor" {
  run LesserThenWithFactor 0 99 100
  [ "$status" -eq 1 ]
  assert_output ''
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

@test "AverageOfDaysTest" {
  AverageOfDaysTest 2
  [ "$averagePriceList" == ',' ] 
  
  AverageOfDaysTest 3
  [ "$averagePriceList" == ', , ,' ]  

  AverageOfDaysTest 14
  [ "$averagePriceList" == ', , , , , , , , , , , , , , , ,' ]  
}
