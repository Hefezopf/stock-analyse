#!/bin/bash
last=$(head -n1 -q values.txt)
echo Last price: $last 
average=$(cat values.txt | awk '{ sum += $1; } END { print sum/100; }')
echo Average 100:$average 
if awk 'BEGIN {exit !('$last' < '$average')}'; then
    echo "buy"
else 
    echo "sell"
fi