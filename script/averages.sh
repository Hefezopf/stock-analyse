#!/bin/bash

export LC_NUMERIC=en_US.UTF-8

# MACD_12_26 function:
# Input: ${x}
# Output: MACDList is comma separted list, lastMACDValue
MACD_12_26() {
    _averagePriceList12Param=$1
    _averagePriceList26Param=$2
    export MACDList
    export lastMACDValue

    # Remove leading commas  
    averagePriceMACD12List=${_averagePriceList12Param:24:10000}
    averagePriceMACD26List=${_averagePriceList26Param:52:10000}

    jj_index=0
    # shellcheck disable=SC2001
    averagePriceMACD26List=$(sed 's/,/ /g' <<< "$averagePriceMACD26List")
    for value26 in $averagePriceMACD26List #$(echo "$averagePriceMACD26List" | sed "s/,/ /g")
    do
        index=$((14 + jj_index))
        kk_index=-1
        # shellcheck disable=SC2001
        averagePriceMACD12List=$(sed 's/,/ /g' <<< "$averagePriceMACD12List")
        for valueMACD12 in $averagePriceMACD12List #$(echo "$averagePriceMACD12List" | sed "s/,/ /g")
        do
            kk_index=$((kk_index + 1))
            if [ "$kk_index" = "$index" ]; then
                value12="$valueMACD12"
                break
            fi
        done 
        jj_index=$((jj_index + 1))

        #difference=$(echo "$value12 $value26" | awk '{print ($1 - $2)}')
        difference=$(echo "scale=2;$value12-$value26" | bc)

        difference=$(printf "%.2f" "$difference")

        # Ignore first incorrect number?!
        if [ "$kk_index" -eq 15 ]; then 
            MACDList="$MACDList , $difference, $difference,"
        fi
        if [ "$kk_index" -gt 15 ]; then 
            MACDList="$MACDList $difference,"
        fi
    done
    difference=$(printf "%.2f" "$difference")
    lastMACDValue=$difference
    MACDList=" , , , , , , , , , , ,$MACDList"
}

# EMAverageOfDays function:
# Input: ${x}
# Output: averagePriceList is comma separted list
EMAverageOfDays() {
    _amountOfDaysParam=${1}
    _dataFileParam=${2}
    _quotesAsArrayParam=("$@") # all params are in this array!!!
    
    export averagePriceList

    averagePriceList=$(seq -s " ," "${_amountOfDaysParam}" | tr -d '[:digit:]')
    # shellcheck disable=SC2206
    _quotesAsArray=(${_quotesAsArrayParam[2]})
    i=0
    while [ "$i" -le $((100-_amountOfDaysParam)) ]; do
        if [ "$i" = 0 ]; then # Frist Loop
            ema=0
            ind=99
            while [ "$ind" -ge $((100-_amountOfDaysParam)) ]; do
                ema=$(echo "${_quotesAsArray[ind]} $ema" | awk '{print ($1 + $2)}')
                ind=$((ind - 1))
            done
            ema=$(echo "$ema $_amountOfDaysParam" | awk '{print ($1 / $2)}')
        else
            #(B17*(2/(12+1))+C16*(1-(2/(12+1))))
            ind=$((100-i-_amountOfDaysParam))
            while [ "$ind" -ge $((100-i-_amountOfDaysParam)) ]; do
                # shellcheck disable=SC2086
                #ema=$(echo "${_quotesAsArray[ind]} $ema" | awk '{print ($1*(2/('$_amountOfDaysParam'+1))+$2*(1-(2/('$_amountOfDaysParam'+1))))}')
                ema=$(echo "scale=2;(${_quotesAsArray[ind]}*(2/('$_amountOfDaysParam'+1))+$ema*(1-(2/('$_amountOfDaysParam'+1))))" | bc)
                ind=$((ind - 1))
            done
        fi
        averagePriceList="$averagePriceList $ema,"
        i=$((i + 1))
    done
}

# AverageOfDays function:
# Input: ${x}
# Output: averagePriceList is comma separted list
AverageOfDays() {
    _amountOfDaysParam=$1
    _dataFileParam=$2
    export averagePriceList

    minusCommas=$((_amountOfDaysParam - 13)) # display from 14 on till 100
    averagePriceList=$(seq -s " ," "${minusCommas}" | tr -d '[:digit:]')

    i=0
    while [ "$i" -le $((100-_amountOfDaysParam)) ]; do
        headLines=$((100-i))
        averagePrice=$(head -n"$headLines" "$_dataFileParam" | tail -"$_amountOfDaysParam" | awk '{ sum += $1; } END { print sum/'"$_amountOfDaysParam"'; }')
        averagePriceList="$averagePriceList $averagePrice,"
        i=$((i + 1))
    done
}

# RSIOfDays function:
# Input: ${x}
# Output: RSIQuoteList is comma separted list, beforeLastRSIQuoteRounded, lastRSIQuoteRounded
RSIOfDays() {
    _amountOfDaysParam=$1
    _dataFileParam=$2
    export RSIQuoteList
    export beforeLastRSIQuoteRounded

    lowestRSI=100
    RSIwinningDaysFile="$(mktemp -p "$TEMP_DIR")"
    RSIloosingDaysFile="$(mktemp -p "$TEMP_DIR")"
    RSIwinningDaysVar=""
    RSIloosingDaysVar=""
    i=1
    while [ "$i" -le 100 ]; do
        i=$((i + 1))
        diffLast2Prices=$(head -n$i "$_dataFileParam" | tail -2 | awk 'p{print p-$0}{p=$0}' )
        isNegativ=${diffLast2Prices:0:1}
        if [ "$isNegativ" = '-' ]; then
            withoutMinusSign=${diffLast2Prices:1:9}
            RSIloosingDaysVar="$RSIloosingDaysVar$withoutMinusSign\n"
            RSIwinningDaysVar=$RSIwinningDaysVar"0\n"
        else
            RSIwinningDaysVar="$RSIwinningDaysVar$diffLast2Prices\n"
            RSIloosingDaysVar=$RSIloosingDaysVar"0\n"
        fi
    done

    echo -e "$RSIloosingDaysVar" > "$RSIloosingDaysFile"
    sed -i '$ d' "$RSIloosingDaysFile"
    echo -e "$RSIwinningDaysVar" > "$RSIwinningDaysFile"
    sed -i '$ d' "$RSIwinningDaysFile"

    i=1
    while [ "$i" -le 100 ]; do
        # Fill with blank comma seperated data
        if [ $i -ge "$_amountOfDaysParam" ]; then # >= 14   
            RSIwinningDaysAvg=$(tail -"$i" "$RSIwinningDaysFile" | head -n"$_amountOfDaysParam" | awk '{ sum += $1; } END { print sum/'"$_amountOfDaysParam"'; }')
            RSIloosingDaysAvg=$(tail -"$i" "$RSIloosingDaysFile" | head -n"$_amountOfDaysParam" | awk '{ sum += $1; } END { print sum/'"$_amountOfDaysParam"'; }')
            if [ "$RSIloosingDaysAvg" = 0 ]; then
                RSIQuote=100
            else
                RSIQuote=$(echo "$RSIwinningDaysAvg $RSIloosingDaysAvg" | awk '{print 100-(100/(1+($1/$2)))}')
                # Slightly different algorithm, but almost see no difference?!
                #RSIQuote=$(echo "$RSIwinningDaysAvg" "$RSIloosingDaysAvg" | awk '{print 100*$1/($1+$2)}')
            fi
            beforeLastRSIQuoteRounded="$lastRSIQuoteRounded"
            lastRSIQuoteRounded=${RSIQuote%.*}
            if [ "$lastRSIQuoteRounded" -lt "$lowestRSI" ]; then
                lowestRSI="$lastRSIQuoteRounded"
            fi

            RSIQuoteList="$RSIQuoteList $lastRSIQuoteRounded,"
        fi
        i=$((i + 1))
    done
}

# StochasticOfDays function:
# Input: ${x}
# Output: stochasticQuoteList is comma separted list, lastStochasticQuoteRounded
StochasticOfDays() {
    _amountOfDaysParam=$1
    _dataFileParam=$2
    export stochasticQuoteList

    stochasticFile="$(mktemp -p "$TEMP_DIR")"
    minusCommas=$((_amountOfDaysParam - 13)) # display from 14 on till 100
    stochasticQuoteList=$(seq -s " ," "${minusCommas}" | tr -d '[:digit:]') 

    i=0
    # TODO optimize not 100 loop?!
    while [ "$i" -le $((100-_amountOfDaysParam)) ]; do
        headLines=$((100-i))
        head -n$headLines "$_dataFileParam" | tail -"$_amountOfDaysParam" > "$stochasticFile"
        lastStochasticRaw=$(head -n 1 "$stochasticFile")
        lowestStochasticRaw=$(sort -g "$stochasticFile" | head -n 1)
        highestStochasticRaw=$(sort -gr "$stochasticFile" | head -n 1)
        if awk 'BEGIN {exit !('"$highestStochasticRaw"' > '"$lowestStochasticRaw"')}'; then
            # Formula=((C – Ln )/( Hn – Ln )) * 100
            #lastStochasticQuote=$(echo "$lastStochasticRaw $lowestStochasticRaw $highestStochasticRaw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
            lastStochasticQuote=$(echo "scale=2;( ($lastStochasticRaw - $lowestStochasticRaw) / ($highestStochasticRaw - $lowestStochasticRaw) ) * 100" | bc)
        else 
            lastStochasticQuote=100
        fi
        #lastStochasticQuoteRounded=$(echo "$lastStochasticQuote" | cut -f 1 -d '.')
        lastStochasticQuoteRounded=${lastStochasticQuote%.*}
        stochasticQuoteList="$stochasticQuoteList $lastStochasticQuoteRounded,"
        i=$((i + 1))
    done
}
