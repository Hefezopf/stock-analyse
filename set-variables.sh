#!/bin/bash
ratedEnv=overrated
#unset ratedEnv
ratedVar="${ratedEnv-underrated}"
echo $ratedVar
./analyse.sh 'DB1.XETRA BMW.XETRA' 2 offline $ratedVar
