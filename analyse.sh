#!/bin/bash
# This script checks given stock quotes and their averages of the last 100, 38, 18 days.
# Call: ./analyse.sh SYMBOLS [offline]
# SYMBOLS - Liste of stock symbols like: 'ADS.XETRA ALV.XETRA BAS.XETRA'
# Optional parameter "offline" do not query over REST API. Instead read local files.
# 1. Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA'
# 2. Call example: ./analyse.sh 'ADS.XETRA ALV.XETRA BAS.XETRA' offline
#
# Set MARKET_STACK_ACCESS_KEY as Env Variable
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"

#LNX.XETRA ??
#symbols='ADS.XETRA ALV.XETRA BAS.XETRA BAYN.XETRA BMW.XETRA BEI.XETRA CBK.XETRA CON.XETRA DAI.XETRA DBK.XETRA DB1.XETRA LHA.XETRA DPW.XETRA DTE.XETRA EOAN.XETRA FME.XETRA FRE.XETRA HEI.XETRA HEN.XETRA IFX.XETRA SDF.XETRA LIN.XETRA MRK.XETRA MUV2.XETRA RWE.XETRA SAP.XETRA SIE.XETRA TKA.XETRA VOW.XETRA'
symbols=$1

#rm -rf ./data/values*.txt
result_file=./data/result.txt
rm -rf $result_file

if [ -z "$MARKET_STACK_ACCESS_KEY" ]; then
	echo Error: MARKET_STACK_ACCESS_KEY not set!
	exit
fi

if [[ $2 == 'offline' ]]; then
	echo Offline Query
else
	echo Online Query
fi
	
for symbol in $symbols
do
    under18=0
    under38=0
	under100=0
    over18=0
    over38=0
	over100=0
	echo "## $symbol ##"
	if [[ $2 == 'offline' ]]; then
		true
	else
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
	
	cp ./data/values.${symbol}.txt ./data/values100.txt
	last=$(head -n1 -q data/values100.txt)
	
	head -n18 ./data/values.${symbol}.txt > ./data/values18.txt
	average18=$(cat ./data/values18.txt | awk '{ sum += $1; } END { print sum/18; }')
	if awk 'BEGIN {exit !('$last' > '$average18')}'; then
	    over18=1
	fi

	if awk 'BEGIN {exit !('$last' < '$average18')}'; then
	    under18=1
	fi

	head -n38 ./data/values.${symbol}.txt > ./data/values38.txt
	average38=$(cat ./data/values38.txt | awk '{ sum += $1; } END { print sum/38; }')
	if awk 'BEGIN {exit !('$last' > '$average38')}'; then
	    over38=1
	fi

	if awk 'BEGIN {exit !('$last' < '$average38')}'; then
	    under38=1
	fi

	average100=$(cat ./data/values100.txt | awk '{ sum += $1; } END { print sum/100; }')
	if awk 'BEGIN {exit !('$last' > '$average100')}'; then
	    over100=1
		
	fi
	if awk 'BEGIN {exit !('$last' < '$average100')}'; then
		under100=1
	fi
	
	if [ $over18 == 1 ] && [ $over38 == 1 ] && [ $over100 == 1 ]; then
		echo "-------> Overrated: $symbol $last over average 18: $average18 and average 38: $average38 and over average 100: $average100"
		echo Overrated: "http://www.google.com/search?tbm=fin&q=${symbol}" >> $result_file
	fi
	
	if [ $under18 == 1 ] && [ $under38 == 1 ] && [ $under100 == 1 ]; then
		echo "++++++++> Underrated: $symbol $last under average 18: $average18 and under average 38: $average38 and under average 100: $average100"
		echo Underrated: "http://www.google.com/search?tbm=fin&q=${symbol}" >> $result_file
	fi
	
	echo " "
done
