#!/bin/bash
percentageDefault=1
queryDefault=offline
ratedDefault=underrated
echo with default parameter: $percentageDefault $queryDefault $ratedDefault

percentageInput=88
queryInput=
ratedInput=

#echo with form input parameter: ${{github.event.inputs.percentageParam}} ${{github.event.inputs.queryParam}} ${{github.event.inputs.ratedParam}}
echo with input parameter: $percentageInput $queryInput $ratedInput

percentageVar=${percentageInput:-$percentageDefault}
queryVar=${queryInput:-$queryDefault}
ratedVar=${ratedInput:-$ratedDefault}

echo with CALCULATED parameter: $percentageVar $queryVar $ratedVar
./analyse.sh 'DB1.XETRA BMW.XETRA' $percentageVar $queryVar $ratedVar
