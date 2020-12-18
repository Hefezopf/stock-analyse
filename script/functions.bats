#!/usr/bin/env bats

# https://github.com/bats-core/bats-core

# Import functions
. ./script/functions.sh

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

@test "RoundNumberToInt" {
  #run RoundNumberToInt 99,9
  #[ "$status" -eq 100 ]
  #[ "$output" == '' ]  

  #run RoundNumberToInt 99,4
  #[ "$status" -eq 99 ]
  #[ "$output" == '' ]  

  run RoundNumberToInt 99,5
  [ "$status" -eq 100 ]
  [ "$output" == '' ]  
}

@test "AverageOfDaysTest" {
  days=2
  run AverageOfDaysTest $days
  [ "$status" -eq 0 ]
  #[ "$output" == ', ' ] 
  #[ "$days" == ',' ]  
  #[ "$days" == 'foo' ]  
  #foo bar rab oof
  
  run AverageOfDaysTest 14
  [ "$status" -eq 0 ]
  #[ "$output" == ', , , , , , , , , , , , ,' ]  
}
