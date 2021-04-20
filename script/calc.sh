#!/bin/sh

# Calculating difference or gain/lost

# Call: sh ./calc.sh ORDERRATE PIECES SPREAD_IN_PERCENT SELLRATE
# Example: sh ./calc.sh 9.99 100 0.1 10.1
# alias calc='/d/code/stock-analyse/script/calc.sh $1 $2 $3 $4'

echo "calc ${1} ${2} ${3} ${4} ..."

if { [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; } then
  echo "Not all parameters specified!"
  echo "Call: ./calc.sh ORDERRATE PIECES SPREAD_IN_PERCENT SELLRATE"
  echo "Example: ./calc.sh 9.99 100 0.1 10.1"
  exit 1
fi

echo ""
echo "Orderrate: $1"€
echo "Pieces:    $2"pc
echo "Spread:    $3"%
echo "Sellrate:  $4"€

orderValue=$(echo "$1 $2" | awk '{print ($1 * $2)}')
# Float to integer
orderValue=${orderValue%.*}

# 3.000 EUR Minimumprovision 8,90 EUR 8,01 EUR 7,12 EUR
# 5.000 EUR 0,25 % from order value 12,50 EUR 11,25 EUR 10,00 EUR
# 10.000 EUR 0,25 % from order value 25,00 EUR 22,50 EUR 20,00 EUR
# 15.000 EUR 0,25 % from order value 37,50 EUR 33,75 EUR 30,00 EUR
# 25.000 EUR Maximalprovision 58,90 EUR 53,01 EUR 47,12 EUR
txFee=7,12
if [ "$orderValue" -gt 25000 ]; then 
    txFee=47.12
elif [ "$orderValue" -gt 15000 ]; then 
    txFee=30.0
elif [ "$orderValue" -gt 10000 ]; then 
    txFee=20.0
elif [ "$orderValue" -gt 5000 ]; then
    txFee=10.0
fi
txFee=$(echo "$txFee 2" | awk '{print $1 * $2}')

spreadFee=$(echo "$1 $2 $3" | awk '{print ($1 * $2 * $3 / 100)}')
sellValue=$(echo "$2 $4" | awk '{print $1 * $2}')
diffValue=$(echo "$sellValue $orderValue $txFee $spreadValue" | awk '{print ($1 - $2 - $3 -$4)}')
percentValue=$(echo "$sellValue $orderValue" | awk '{print (($1 / $2 * 100) - 100)}')
afterTaxValue=$(echo "$diffValue 1.25" | awk '{print $1 / $2}')

echo ""
echo "Order Value: $orderValue"€
echo "Tx Fee:     -"$txFee€
echo "Spread Fee: -"$spreadFee€
echo "Sell Value:  $sellValue"€
echo "Difference:  $diffValue"€
echo "Percent:     $percentValue"%

isNegativ=$(echo "${afterTaxValue}" | awk '{print substr ($0, 0, 1)}')
if [ "${isNegativ}" != '-' ]; then
  echo "After Tax:   $afterTaxValue"€
fi
