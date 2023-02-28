#!/usr/bin/env bash

export TERM=xterm # Solved warning in github action
clear && rm -rf $HOME/test/test_helper/batscore  && rm -rf $HOME/test/test_helper/batsassert
git clone https://github.com/bats-core/bats-core.git $HOME/test/test_helper/batscore
git clone https://github.com/bats-core/bats-assert.git $HOME/test/test_helper/batsassert

#ls -lias $HOME/test/test_helper/batscore/install.sh
#chmod +x $HOME/test/test_helper/batscore/install.sh

#. $HOME/test/test_helper/batscore/install.sh ~
. $HOME/test/test_helper/batscore/bin/bats -v