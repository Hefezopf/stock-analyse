#!/usr/bin/env bash

# Call: sh ./script/marktkapitalisierung.sh SYMBOLS
# Example: sh ./script/marktkapitalisierung.sh 'BEI VH2' 
# alias ???='/d/code/stock-analyse/script/marktkapitalisierung.sh $1'

# Marktkapitalisierung only Mio!: VH2 "FRIEDRICH VORWERK":ID_NOTATION=328873513
# Marktkapitalisierung only Mio!: SGL "SGL CARBON":ID_NOTATION=10336984
# Marktkapitalisierung only Mio!: NWO "New Work":ID_NOTATION=46672415
# Marktkapitalisierung only Mio!: MOR "MorphoSys":ID_NOTATION=10336962
# Marktkapitalisierung only Mio!: AAD "AMADEUS FIRE":ID_NOTATION=260319088
# Marktkapitalisierung only Mio!: DEQ "DEUT. EUROSHOP":ID_NOTATION=10508226
# Marktkapitalisierung only Mio!: DEZ "DEUTZ":ID_NOTATION=46672469
# Marktkapitalisierung only Mio!: INH "INDUS":ID_NOTATION=10336938
# Marktkapitalisierung only Mio!: LEO "LEONI":ID_NOTATION=10336891
# Marktkapitalisierung only Mio!: MLP "MLP":ID_NOTATION=10233937
# Marktkapitalisierung only Mio!: NOEJ "NORMA":ID_NOTATION=46672364
# Marktkapitalisierung only Mio!: NXU "NEXUS":ID_NOTATION=3241269
# Marktkapitalisierung only Mio!: RHK "RHOEN-KLINIKUM":ID_NOTATION=15083507
# Marktkapitalisierung only Mio!: RWE "ERWE IMMOBILIEN":ID_NOTATION=243027022
# Marktkapitalisierung only Mio!: SANT "S & T":ID_NOTATION=171231810
# Marktkapitalisierung only Mio!: SFQ "SAF-HOLLAND":ID_NOTATION=18418227
# Marktkapitalisierung only Mio!: SHA "SCHAEFFLER":ID_NOTATION=144386033
# Marktkapitalisierung only Mio!: TTK "TAKKT":ID_NOTATION=47173648
# Marktkapitalisierung only Mio!: VOS "VOSSLOH":ID_NOTATION=10337036

TICKER_NAME_ID_FILE=../config/ticker_name_id.txt
symbolsParam=$1

for symbol in $symbolsParam
do
  # Remove prefix '*' if persent
  if [ "$(echo "$symbol" | cut -b 1-1)" = '*' ]; then
    symbol=$(echo "$symbol" | cut -b 2-6)
  fi
  ID_NOTATION=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 3)
  SYMBOL_NAME=$(grep -m1 -P "$symbol\t" $TICKER_NAME_ID_FILE | cut -f 2)
  #echo $symbol $SYMBOL_NAME:ID_NOTATION=$ID_NOTATION

  result=$(curl -s --location --request GET "https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=$ID_NOTATION" | grep -ioF "Mio.&nbsp;EUR<")
  if [ "$result" ]; then
    echo Marktkapitalisierung only Mio!: $symbol $SYMBOL_NAME:ID_NOTATION=$ID_NOTATION
  fi
done