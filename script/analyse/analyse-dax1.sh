#!/bin/bash

#./analyse.sh 'ADS BMW' 1 offline 9
set -x
./analyse.sh 'DB1' $1 $2 $3 $4
start chrome out/DB1.html
