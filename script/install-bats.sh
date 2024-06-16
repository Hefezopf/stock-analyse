#!/bin/bash

export TERM=xterm # Solved warning in github action

clear && rm -rf $HOME/test/test_helper/batscore && rm -rf $HOME/test/test_helper/batsassert

git clone https://github.com/bats-core/bats-core.git $HOME/test/test_helper/batscore
#git clone https://github.com/bats-core/bats-core.git --branch=v1.9.0 $HOME/test/test_helper/batscore
git clone https://github.com/bats-core/bats-assert.git $HOME/test/test_helper/batsassert
#git clone https://github.com/bats-core/bats-assert.git --branch=v2.1.0 $HOME/test/test_helper/batsassert
