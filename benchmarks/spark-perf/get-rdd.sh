#!/bin/bash

if [ -z "$1" ]; then
  echo "Help Menu"
  echo ""
  echo "\"get-rdd.sh <path to app-id's executor logs>\" runs for only the specified benchmark"
  echo ""
  echo "Example:"
  echo "    \"get-rdd.sh logs/2016-07-14_23-36-06/glm-regression/executor_logs/app-20160714233708-0000\""
  echo ""
  exit 0
fi

start_dir=$(pwd)

# If the second argument doesn't exist it must be the case that we are not doing
# all of the logs, but just a specific benchmark
if [ -z "$2" ]; then
  # In this case, the target directory is specified by $1, so go there
  cd "$1"
  specified_dir=$(pwd)

  appid=`expr match "$1" '.*\(app-[0-9]\{14\}-[0-9]\{4\}*\)'`

  hits_file="rdd_hits.txt"
  misses_file="rdd_misses.txt"
  evictions_file="rdd_evictions.txt"
  size_file="rdd_size.txt"
  computation_file="rdd_computation.txt"
  hits_ratio_file="rdd_hits_ratio.txt"
  misses_ratio_file="rdd_misses_ratio.txt"

  destination="../../rdd_hits_and_misses/${appid}"
  mkdir -p "$destination"


  rm -rf "$destination"/"$hits_file"
  touch "$destination"/"$hits_file"

  rm -rf "$destination"/"$hits_ratio_file"
  touch "$destination"/"$hits_ratio_file"

  rm -rf "$destination"/"$misses_file"
  touch "$destination"/"$misses_file"

  rm -rf "$destination"/"$misses_ratio_file"
  touch "$destination"/"$misses_ratio_file"

  rm -rf "$destination"/"$evictions_file"
  touch "$destination"/"$evictions_file"

  rm -rf "$destination"/"$size_file"
  touch "$destination"/"$size_file"

  rm -rf "$destination"/"$computation_file"
  touch "$destination"/"$computation_file"

  # Combine all app log files into one file called rdd_hits.txt
  grep 'found block rdd_[0-9]\{1,\}_[0-9]\{1,\}' * -Ri > "$destination"/"$hits_file"
  grep 'Partition rdd_[0-9]\{1,\}_[0-9]\{1,\} not found, computing it' * -Ri > "$destination"/"$misses_file"
  grep 'Dropping block' * -Ri > "$destination/$evictions_file"
  grep 'stored as values in memory' * -Ri | grep 'rdd' > "$destination/$size_file"
  grep 'computed and cached in' * -Ri > "$destination/$computation_file"

  # Delete everything from beginning of line to first occurrence of "rdd"
  sed -i 's/^.*rdd/rdd/p' "$destination"/"$hits_file"
  sed -i 's/^.*rdd/rdd/p' "$destination"/"$misses_file"
  sed -i 's/^.*rdd/rdd/p' "$destination"/"$evictions_file"
  sed -i 's/^.*rdd/rdd/p' "$destination"/"$size_file"
  sed -i 's/^.*rdd/rdd/p' "$destination"/"$computation_file"

  # Delete from the end of the rdd tag (denoted by a space) to the eol
  sed -i "s@ .*@@g" "$destination"/"$hits_file"
  sed -i "s@ .*@@g" "$destination"/"$misses_file"
  sed -i "s@ .*@@g" "$destination"/"$evictions_file"
  sed -i "s@ .*estimated size@  @g" "$destination"/"$size_file"
  sed -i "s@, .*@@g" "$destination"/"$size_file"
  sed -i "s@ .*computed and cached in@@g" "$destination"/"$computation_file"


else
  echo "error"
  exit 1
fi

cd "$destination"

cp "$hits_file" master
cat "$misses_file" >> master

# remove duplicates and find number of occurences
sort "$hits_file" | uniq -c > tmp && mv tmp "$hits_file"
sort -bnr "$hits_file" > tmp && mv tmp "$hits_file"

sort "$misses_file" | uniq -c > tmp && mv tmp "$misses_file"
sort -bnr "$misses_file" > tmp && mv tmp "$misses_file"

sort "$evictions_file" | uniq -c > tmp && mv tmp "$evictions_file"
sort -bnr "$evictions_file" > tmp && mv tmp "$evictions_file"

sort -bnr "$computation_file" > tmp && mv tmp "$computation_file"

sort master | uniq -c > tmp && mv tmp master
sort -bnr master > tmp && mv tmp master

# remove leading spaces
sed -i 's/^[ \t ]*//' "$hits_file"
sed -i 's/^[ \t ]*//' "$misses_file"
sed -i 's/^[ \t ]*//' "$evictions_file"
sed -i 's/^[ \t ]*//' master

cp "$hits_file" "$hits_ratio_file"
cp "$misses_file" "$misses_ratio_file"
cp master master_ratio

# put numbers and rdd names on different lines
sed -i "s/ /\n/g" "$hits_ratio_file"
sed -i "s/ /\n/g" "$misses_ratio_file"
sed -i "s/ /\n/g" master_ratio

# Extract the rdd numbers
sed -i "s/rdd_//g" "$hits_ratio_file"
sed -i "s/rdd_//g" "$misses_ratio_file"
sed -i "s/rdd_//g" master_ratio

sed -i "s/_/\n/g" "$hits_ratio_file"
sed -i "s/_/\n/g" "$misses_ratio_file"
sed -i "s/_/\n/g" master_ratio

# first value is the number of times the rdd is accessed
# second number is identifier
# third is block id

# Gives number of hits for an rdd given an id and blockid
declare -A hit_array
exec 10<&0
fileName="$hits_ratio_file"
exec < $fileName
let count=0

# Populate the array
while read LINE; do
  if (( count % 3 == 0 )); then
    occurences=$LINE
  elif (( count % 3 == 1 )); then
    id=$LINE
  else
    block_id=$LINE
    hit_array[$id,$block_id]=$occurences
  fi
  ((count++))
done
exec 0<&10 10<&-


# Gives number of misses for an rdd given an id and blockid
declare -A miss_array
exec 10<&0
fileName="$misses_ratio_file"
exec < $fileName
let count=0

while read LINE; do
  if (( count % 3 == 0 )); then
    occurences=$LINE
  elif (( count % 3 == 1 )); then
    id=$LINE
  else
    block_id=$LINE
    miss_array[$id,$block_id]=$occurences
  fi
  ((count++))
done
exec 0<&10 10<&-


# Holds the information for the total accesses of all rdds given an rdd id and blockid
declare -A master_ratio

# holds rdd id information for a given index
declare -a master_id

# holds blockid information for a given index
declare -a master_blockid
exec 10<&0
fileName="master_ratio"
exec < $fileName
let count=0
let id_count=0
let blockid_count=0

while read LINE; do
  if (( count % 3 == 0 )); then
    occurences=$LINE
  elif (( count % 3 == 1 )); then
    id=$LINE
    master_id[$id_count]=$LINE
    ((id_count++))
  else
    block_id=$LINE
    master_blockid[$blockid_count]=$LINE
    master_ratio[$id,$block_id]=$occurences
    ((blockid_count++))
  fi
  ((count++))
done
exec 0<&10 10<&-

rm -rf master
rm -rf master_ratio

rm -rf rdd_hits_ratio.txt
rm -rf rdd_misses_ratio.txt

for((i=0;i<id_count;i++)); do
  misses=${miss_array[${master_id[$i]},${master_blockid[$i]}]}
  total=${master_ratio[${master_id[$i]},${master_blockid[$i]}]}
  miss_rate=$(echo "scale=3; ($misses*100 / $total)" | bc -l)
  hit_rate=$(echo "(100 - $miss_rate)" | bc -l)

  echo "$hit_rate rdd_${master_id[$i]}_${master_blockid[$i]}" >> rdd_hits_ratio.txt
  echo "$miss_rate rdd_${master_id[$i]}_${master_blockid[$i]}" >> rdd_misses_ratio.txt
done

# sort "$hits_ratio_file" | uniq -c > tmp && mv tmp "$hits_ratio_file"
sort -bnr "$hits_ratio_file" > tmp && mv tmp "$hits_ratio_file"

# sort "$misses_ratio_file" | uniq -c > tmp && mv tmp "$misses_ratio_file"
sort -bnr "$misses_ratio_file" > tmp && mv tmp "$misses_ratio_file"

relative_path=$(echo "$(pwd)" | sed "s/.*logs/logs/g")

echo "Files saved in $relative_path"
