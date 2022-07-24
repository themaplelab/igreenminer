#!/bin/bash

# This bashscript takes two arguments
# First arguments selects the xCode project $1
# Second script writes the output .csv file name for energy consumption $2

#./runSingleTestCase.sh -w /Users/greenali/Desktop/loopEnergy/RealAppsEval/CartrackTech/CartrackTechChallenge/CartrackTechChallenge.xcworkspace -s CartrackTechChallenge -c AccountServiceTests -k CartrackTechChallengeTests -t testGetCountryList -f /Users/greenali/Desktop/loopEnergy/RealAppsEval/CartrackTech/CartrackTechChallenge

helpFunction()
{
   echo ""
   echo "Usage: $0 -p xcodeProjPath -o outputEnergyCsvPath -t testTimeSeconds"
   echo -e "\t-p Path of the Xcode Project to execute"
   echo -e "\t-o Path of the Monsoon Output file for energy measurements"
   echo -e "\t-t Time to run the test cases (seconds)"
   echo -e "\t-e Aggregate energy file path"
   exit 1 # Exit script after printing help
}

while getopts "p:w:o:t:e:c:t:k:s:f:" opt
do
   case "$opt" in
      p ) xcodeProjPath="$OPTARG" ;;
      w ) xcodeWsPath="$OPTARG" ;;
      o ) outputEnergyCsvPath="$OPTARG" ;;
      t ) testTime="$OPTARG" ;;
      e ) energyFile="$OPTARG" ;;
      c ) class_name="$OPTARG" ;;
      t ) test_method="$OPTARG" ;;
      k ) test_package="$OPTARG" ;;
      s ) scheme="$OPTARG" ;;
      f ) project_folder="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
#if [ -z "$xcodeProjPath" ] || [ -z "$outputEnergyCsvPath" ]
if [ -z "$xcodeProjPath" ] && [ -z "$xcodeWsPath" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
xPath=$xcodeProjPath
csvPath=$outputEnergyCsvPath
startSamplingScript="/Users/abdulalib/Desktop/greenminer/monsoon-0.1.88/startSamplingToFileArgs.py"

echo $xPath
echo $csvPath
echo python $startSamplingScript -o $csvPath -t $testTime &

#python $startSamplingScript -o $csvPath -t $((testTime*60))  &
#echo "Sampling start time:  $(date '+%T')" 2>&1 | tee $csvPath+"sampleStartTime.txt"
test_location=$test_package"/"$class_name"/"$test_method

(cd $project_folder; pod install)
if [ -z "$xcodeProjPath" ]
then
  echo xcodebuild test -workspace $xcodeWsPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location
  #xcodebuild test -workspace $xcodeWsPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
  DEVELOPMENT_TEAM="abdul bangash"; xcodebuild test -workspace $xcodeWsPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt" 
else
  echo xcodebuild test -project $xPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location
  xcodebuild test -project $xPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
fi

sleep 2
#pkill -9 -f /Users/abdulalib/Desktop/greenminer/monsoon-0.1.88/startSamplingToFileArgs.py

# Running extra python script in the next line to throw an error and get serial port rid of the parallel process
#echo "Flush: "python $startSamplingScript -o $csvPath+"err.csv" -t 1
#python $startSamplingScript -o $csvPath+"err.csv" -t 1 > /dev/null 2>&1

#echo python3 aggregateResults.py -s $csvPath+"sampleStartTime.txt" -x $csvPath+"xcode.txt" -o $csvPath -e $energyFile
#python3 aggregateResults.py -s $csvPath+"sampleStartTime.txt" -x $csvPath+"xcode.txt" -o $csvPath -e $energyFile

#rm $csvPath+"err.csv"
#echo "exiting the script"

exit
