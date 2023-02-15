#myAssociativeArray=();

# 2023-02-13	71.2
# 2023-02-10	72.3
# 2023-02-09	72.6
myAssociativeArray[0]="71.2"
myAssociativeArray[1]="72.3"



for pos in "${!myAssociativeArray[@]}"; do
  echo -n "Pos: "$pos", "
  echo "value: ${myAssociativeArray[$pos]}"
done

