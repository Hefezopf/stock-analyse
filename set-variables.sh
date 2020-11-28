#!/bin/bash
percentageEnv=2
#percentageInput=3
#unset percentageEnv
#unset percentageInput
percentageVar=${percentageInput:-$percentageEnv}
#percentageVar="${percentageEnv-percentageInput}"
#percentageVar="${percentageEnv-3}"
echo percentage $percentageVar
./analyse.sh 'DB1.XETRA BMW.XETRA' $percentageVar offline underrated
