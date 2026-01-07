#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Constants
SYMBOL=BEI

@test "Simulation" {
  #result=$(./simulate.sh $SYMBOL 2500 15 71 1.01 5 1)
 # run ./simulate.sh $SYMBOL 2500
  #[ "$status" -eq 0 ]

  run ./simulate.sh $SYMBOL 2500 15 71 1.01 5 1
  #[ "$status" -eq 0 ]

  #echo "result: "$result
  #[[ "${result}" =~ 'xxxxxxxxxxxxxxxxxxxxxx' ]]

  run git checkout simulate/out/*.html
}
