#!/bin/bash
# Script wertet die Kurse der letzten 100, 38 Tage aus.
# Aufruf: ./analyse.sh [offline]
# Optionaler Parameter "offline" wenn nicht über REST API angefragt wird. Sonst werden lokale Files hergenommen.
#
# export MARKET_STACK_ACCESS_KEY="a310b2410e8ca3c818a281b4eca0b86f"
#

#symbols='ALV.XETRA VOW.XETRA'

#LNX.XETRA ??
symbols='ADS.XETRA ALV.XETRA BAS.XETRA BAYN.XETRA BMW.XETRA BEI.XETRA CBK.XETRA CON.XETRA DAI.XETRA DBK.XETRA DB1.XETRA LHA.XETRA DPW.XETRA DTE.XETRA EOAN.XETRA FME.XETRA FRE.XETRA HEI.XETRA HEN.XETRA IFX.XETRA SDF.XETRA LNX.XETRA LIN.XETRA MRK.XETRA MUV2.XETRA RWE.XETRA SAP.XETRA SIE.XETRA TKA.XETRA VOW.XETRA'

#rm -rf data/values*.txt

if [[ $1 == 'offline' ]]; then
	echo offline
else
	echo online
fi
	
for symbol in $symbols
do
    under38=0
	under100=0
    over38=0
	over100=0
	echo "## $symbol ##"
	if [[ $1 == 'offline' ]]; then
		true
		#echo offline
	else
	    #echo online
		curl -s --location --request GET "http://api.marketstack.com/v1/eod?access_key=${MARKET_STACK_ACCESS_KEY}&exchange=XETRA&symbols=${symbol}" | jq '.data[].close' > ./data/values.${symbol}.txt
	fi
	
	cp ./data/values.${symbol}.txt ./data/values100.txt
	last=$(head -n1 -q data/values100.txt)
	
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
	
	if [ $over38 == 1 ] && [ $over100 == 1 ]; then
		echo "------------------------> Sell: $symbol $last over average 38: $average38 and over average 100: $average100"
	fi
	
	if [ $under38 == 1 ] && [ $under100 == 1 ]; then
		echo "++++++++++++++++++++++++> Buy: $symbol $last under average 38: $average38 and under average 100: $average100"
	fi
	
	echo " "
done
