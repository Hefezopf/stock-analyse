#!/bin/sh

export LC_NUMERIC=en_US.UTF-8

# MACD_12_26 function:
# Input: ${x}
# Output: MACDList is comma separted list, lastMACDValue
MACD_12_26() {
    _averagePriceList12Param=${1}
    _averagePriceList26Param=${2}

    # Remove leading commas
    averagePriceMACD12List=$(echo "$_averagePriceList12Param" | cut -b 24-10000)
    averagePriceMACD26List=$(echo "$_averagePriceList26Param" | cut -b 52-10000)

    jj_index=0
    # shellcheck disable=SC2001
    for value26 in $(echo "$averagePriceMACD26List" | sed "s/,/ /g")
    do
        index=$((14 + jj_index))
        kk_index=-1
        # shellcheck disable=SC2001
        for valueMACD12 in $(echo "$averagePriceMACD12List" | sed "s/,/ /g")
        do
            kk_index=$((kk_index + 1))
            if [ "$kk_index" = "$index" ]; then
                value12="$valueMACD12"
                break
            fi
        done 
        jj_index=$((jj_index + 1))
        difference=$(echo "$value12 $value26" | awk '{print ($1 - $2)}')
        difference=$(printf "%.2f" $difference)
        MACDList="$MACDList $difference,"     
    done
    difference=$(printf "%.2f" $difference)
    lastMACDValue=$difference
    MACDList=" , , , , , , , , , , , , , , ,$MACDList"
}

# EMAverageOfDays function:
# Input: ${x}
# Output: averagePriceList is comma separted list
EMAverageOfDays() {
    _amountOfDaysParam=${1}
    _dataFileParam=${2}

    minusCommas=$((_amountOfDaysParam - 10)) # display from 11 on till 100
    i=1
    while [ "$i" -lt "$minusCommas" ]; do # Fill with blank comma seperated data
        averagePriceList="$averagePriceList ,"        
        i=$((i + 1))
    done 

    i=0
    while [ "$i" -le $((100-_amountOfDaysParam)) ]; 
    do
        if [ "$i" = 0 ]; then # Frist Loop
            headLines=$((100-i))
            ema=$(head -n"$headLines" "$_dataFileParam" | tail -"${_amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'"${_amountOfDaysParam}"'; }')         
        else
            #(B17*(2/(12+1))+C16*(1-(2/(12+1))))
            headLinesLastPrice=$((101-i-_amountOfDaysParam))
            lastPrice=$(head -n"$headLinesLastPrice" "$_dataFileParam" | tail -1)
            # shellcheck disable=SC2086
            ema=$(echo "$lastPrice $ema" | awk '{print ($1*(2/('${_amountOfDaysParam}'+1))+$2*(1-(2/('${_amountOfDaysParam}'+1))))}')          
        fi
        averagePriceList="$averagePriceList $ema,"
        i=$((i + 1))
    done
}

# AverageOfDays function:
# Input: ${x}
# Output: averagePriceList is comma separted list
AverageOfDays() {
    _amountOfDaysParam=${1}
    _dataFileParam=${2}

    minusCommas=$((_amountOfDaysParam - 10)) # display from 11 on till 100
    i=1
    while [ "$i" -lt "$minusCommas" ]; do # Fill with blank comma seperated data
        averagePriceList="$averagePriceList ,"
        i=$((i + 1))
    done

    i=0
    while [ "$i" -le $((100-_amountOfDaysParam)) ];
    do
        headLines=$((100-i))
        averagePrice=$(head -n"$headLines" "$_dataFileParam" | tail -"${_amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'"${_amountOfDaysParam}"'; }')
        averagePriceList="$averagePriceList $averagePrice,"
        i=$((i + 1))
    done
}

# RSIOfDays function:
# Input: ${x}
# Output: RSIQuoteList is comma separted list
RSIOfDays() {
    _amountOfDaysParam=${1}
    _dataFileParam=${2}
    RSIwinningDaysFile="$(mktemp -p /dev/shm/)"
    RSIloosingDaysFile="$(mktemp -p /dev/shm/)"
    i=1
    while [ "$i" -le 100 ];
    do
        i=$((i + 1))
        diffLast2Prices=$(head -n$i "$_dataFileParam" | tail -2 | awk 'p{print p-$0}{p=$0}' )
        isNegativ=$(echo "${diffLast2Prices}" | awk '{print substr ($0, 0, 1)}')
        if [ "${isNegativ}" = '-' ]; then
            withoutMinusSign=$(echo "${diffLast2Prices}" | awk '{print substr ($1, 2, 9)}')
            echo "$withoutMinusSign" >> "$RSIloosingDaysFile"
            echo "0" >> "$RSIwinningDaysFile"
        else
            echo "0" >> "$RSIloosingDaysFile"
            echo "$diffLast2Prices" >> "$RSIwinningDaysFile"
        fi
    done

    RSIQuoteList=" , , ,"
    i=1
    while [ "$i" -le 100 ];
    do
        i=$((i + 1))
        # Fill with blank comma seperated data  
        if [ $i -lt $((_amountOfDaysParam + 1)) ]; then # < 14
            # RSIQuoteList="$RSIQuoteList ,"
J=1
        else # > 14
            RSIwinningDaysAvg=$(tail -"${i}" "$RSIwinningDaysFile" | head -n"${_amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'"${_amountOfDaysParam}"'; }')
            RSIloosingDaysAvg=$(tail -"${i}" "$RSIloosingDaysFile" | head -n"${_amountOfDaysParam}" | awk '{ sum += $1; } END { print sum/'"${_amountOfDaysParam}"'; }') 
            if [ "${RSIloosingDaysAvg}" = 0 ]; then
                RSIQuote=100
            else
                RSIQuote=$(echo "$RSIwinningDaysAvg $RSIloosingDaysAvg" | awk '{print 100-(100/(1+($1/$2)))}')
                # slightly differant algorithm
                #RSIQuote=$(echo "$RSIwinningDaysAvg" "$RSIloosingDaysAvg" | awk '{print 100*$1/($1+$2)}')
            fi

            lastRSIQuoteRounded=$(echo "$RSIQuote" | cut -f 1 -d '.')
            RSIQuoteList="$RSIQuoteList $lastRSIQuoteRounded,"
        fi
    done  
}

# StochasticOfDays function:
# Input: ${x}
# Output: stochasticQuoteList is comma separted list
StochasticOfDays() {
    _amountOfDaysParam=${1}
    _dataFileParam=${2}

    stochasticFile="$(mktemp -p /dev/shm/)"
    minusCommas=$((_amountOfDaysParam - 10)) # display from 11 on till 100
    i=1
    # Fill with blank comma seperated data
    while [ "$i" -lt "$minusCommas" ]; do 
        stochasticQuoteList="$stochasticQuoteList ,"
        i=$((i + 1))
    done 

    i=0
    # TODO optimize not 100 loop?!
    while [ "$i" -le $((100-_amountOfDaysParam)) ];
    do
        headLines=$((100-i))
        head -n$headLines "$_dataFileParam" | tail -"${_amountOfDaysParam}" > "$stochasticFile"
        lastStochasticRaw=$(head -n 1 "$stochasticFile")
        lowestStochasticRaw=$(sort -g "$stochasticFile" | head -n 1)
        highestStochasticRaw=$(sort -gr "$stochasticFile" | head -n 1)

        if awk 'BEGIN {exit !('"$highestStochasticRaw"' > '"$lowestStochasticRaw"')}'; then
            # Formula=((C – Ln )/( Hn – Ln )) * 100
            lastStochasticQuote=$(echo "$lastStochasticRaw $lowestStochasticRaw $highestStochasticRaw" | awk '{print ( ($1 - $2) / ($3 - $2) ) * 100}')
        else 
            lastStochasticQuote=100
        fi
        lastStochasticQuoteRounded=$(echo "$lastStochasticQuote" | cut -f 1 -d '.')
        stochasticQuoteList="$stochasticQuoteList $lastStochasticQuoteRounded,"
        i=$((i + 1))
    done
}
