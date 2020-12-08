#!/bin/bash
#./analyse.sh 'ADS.XETRA BMW.XETRA' 1 offline underrated 9
set -x
./analyse.sh 'DB1.XETRA' $1 $2 $3 $4
start chrome out/DB1.XETRA.html
