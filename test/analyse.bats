#!/usr/bin/env bats

# https://github.com/bats-core/bats-core
# load '/d/code/bats-assert/load.bash'

# Debug mode
#set -x

# Constants
SYMBOL=BEI

@test "Analyse" {
  run ./analyse.sh "$SYMBOL"
  [ "$status" -eq 5 ]

  run git checkout out/*.html
  run git checkout history/*.txt
}
