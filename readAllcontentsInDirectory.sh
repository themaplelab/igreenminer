#!/bin/bash

# Begin script

array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
    IFS='/' read -ra my_array <<< "$REPLY"
    echo "$REPLY"
    echo ${my_array[${#my_array[@]}-2]}
done < <(find /Users/abdulalib/Desktop/greenminer/iOS/LocationBenchmarks -name "*.xcodeproj" -print0)

exit
