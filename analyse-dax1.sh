#!/bin/bash
#./analyse.sh 'ADS BMW' 1 offline underrated 9
set -x
./analyse.sh 'DB1' $1 $2 $3 $4 $5
start chrome out/DB1.html
