#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Constants
SYMBOL=BEI

@test "Analyse" {
  #result=$(./analyse.sh $SYMBOL 2 offline 9 25 ccccccc)
  run ./analyse.sh $SYMBOL
  [ "$status" -eq 5 ]

  #run ./analyse.sh $SYMBOL 2 offline 9 25
  #[ "$status" -eq 0 ]

  #echo "result: "$result
  #[[ "${result}" =~ 'xxxxxxxxxxxxxxxxxxxxxx' ]]

  run git checkout out/*.html
  run git checkout history/*.txt
}
