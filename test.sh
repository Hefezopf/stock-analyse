#!/bin/bash
# https://github.com/bats-core/bats-core
# https://github.com/ztombol/bats-assert

# git clone https://github.com/bats-core/bats-core.git
# git clone https://github.com/bats-core/bats-assert.git
# cd bats-core
# ./install.sh ~
# Es werden 4 dirs in ~ angelegt 
# libexec, bin share und lib
# bats -version

#./../bats-core/bin/bats --tap script/functions.bats
bats --tap script/*.bats