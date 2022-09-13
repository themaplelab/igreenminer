#!/bin/bash

# If the benchmarks doesnt have pre-requirements
#./runAllBenchmarks.sh -p /Users/abdulalib/Desktop/loopEnergy/Benchmarks/insertion/1000 -o /Users/abdulalib/Desktop/loopEnergy/Output/insertionAli
#./runAllBenchmarks.sh -p /Users/greenali/Desktop/loopEnergy/RealAppsEval/CartrackTechProject/commits/cfba5c8 -o /Users/greenali/Desktop/loopEnergy/RealAppsEval/CartrackTechProject/output
# If the benchmarks have pre-requirements
#./runAllBenchmarks.sh -p /Users/abdulalib/Desktop/loopEnergy/Benchmarks/insertion/1000 -o /Users/abdulalib/Desktop/loopEnergy/Output/insertionAli -r /Path/to/prereq/project

#path=/Users/greenali/Desktop/loopEnergy/RealAppsEval/inventarioProject/commits/*; for i in $path; do (./runAllBenchmarks.sh -p $i -o /Users/greenali/Desktop/loopEnergy/RealAppsEval/inventarioProject/output); done

helpFunction()
{
   echo ""
   echo "Usage: $0 -p benchmarkFolderPath"
   echo -e "\t-p Path of the main Benchmarks folder"
   echo -e "\t-o Path of the Monsoon Output Folder for energy measurements"
   echo -e "\t-r Path of the pre-execution project"
   exit 1 # Exit script after printing help
}

while getopts "p:o:r:" opt
do
   case "$opt" in
      p ) benchmarkFolderPath="$OPTARG" ;; #/Users/abdulalib/Desktop/greenminer/iOS/LocationBenchmarks
      o ) outputCSVFolder="$OPTARG" ;; #/Users/abdulalib/Desktop/greenminer/iOS/RunLocationBenchmark/data/
      r ) preExecProjectPath="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$benchmarkFolderPath" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

IFS=$'\n'
paths=($(find $benchmarkFolderPath -name "*.xcworkspace" -not -path "*.xcodeproj/*"))
unset IFS
size_of_ws_array="${#paths[@]}"
if [ $size_of_ws_array -gt 0 ]; then
  find_cmd="find $benchmarkFolderPath -name "*.xcworkspace"  -not -path "*.xcodeproj/*" -print0"
else
  find_cmd="find $benchmarkFolderPath -name "*.xcodeproj" -print0"
fi

#For printing the array of paths
#printf "%s\n" "${paths[@]}"

# Begin script
for testRun in {1..10}
do
  array=()
  # Loop extracting all the .xcodeproj file paths and their types e.g. StandardAPI_Best65536m
  while IFS=  read -r -d $'\0';
  do
    array+=("$REPLY")
    IFS='/' read -ra my_array <<< "$REPLY"
    projectPath="$REPLY"
    #echo "array is " $array
    echo "projectPath is "$projectPath
     #/Users/abdulalib/Desktop/greenminer/iOS/LocationBenchmarks/RegionalAPI/Journal.xcodeproj
    benchmarkName=${my_array[${#my_array[@]}-2]} #regionalAPI
    if [[ ! -e $outputCSVFolder/TotalEnergy.csv ]]; then
      echo "file,benchmark,testrun,energy,totaltime,current,voltage,teststarttime,testendtime" > $outputCSVFolder/TotalEnergy.csv
    fi

    if [ ! -z "$preExecProjectPath" ]
    then
       echo "Run pre-requisite: $preExecProjectPath"
       sh runSingleBenchmark.sh -p $preExecProjectPath -o "$outputCSVFolder/$benchmarkName"__"$testRun.csv"
    fi

    #Loop executing the test cases
    echo "Test Run $testRun for $projectPath"
    echo runSingleBenchmark.sh -p "$projectPath" -o "$outputCSVFolder/$benchmarkName"__"$testRun.csv" -t 1200 -e "$outputCSVFolder/TotalEnergy.csv"
    sh runSingleBenchmark.sh -p "$projectPath" -o "$outputCSVFolder/$benchmarkName"__"$testRun.csv" -t 1200 -e "$outputCSVFolder/TotalEnergy.csv"

    sleep 2
  done < <($find_cmd)
done

exit
