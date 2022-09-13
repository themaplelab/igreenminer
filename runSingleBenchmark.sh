#!/bin/bash

# This bashscript takes two arguments
# First arguments selects the xCode project $1
# Second script writes the output .csv file name for energy consumption $2

#open -a Xcode "/Users/abdulalib/Desktop/greenminer/iOS/LocationTest/StandardAPI_Kilometer256m/Journal.xcodeproj"
#open XcodeRunningScript.app
#!/bin/bash

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

while getopts "p:o:t:e:" opt
do
   case "$opt" in
      p ) xcodeProjPath="$OPTARG" ;;
      o ) outputEnergyCsvPath="$OPTARG" ;;
      t ) testTime="$OPTARG" ;;
      e ) energyFile="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$xcodeProjPath" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
xPath=$xcodeProjPath
csvPath=$outputEnergyCsvPath
startSamplingScript="/Users/greenali/Desktop/greenminer/monsoon-0.1.88/startSamplingToFileArgs.py"

echo $xPath
echo $csvPath

# Exceptional case where a pre-coditional xcode project is run and its energy is not calculated
if [ -z "$energyFile" ]
then
  echo "Preparing to run pre-req project"
  echo xcodebuild test -project $xPath/DBDemo.xcodeproj -scheme DBDemo -destination "platform=iOS,name=Green’s iPhone" -only-testing DBDemoUITests/DBDemoUITests/testExample -allowProvisioningUpdates
  xcodebuild test -project $xPath/DBDemo.xcodeproj -scheme DBDemo -destination "platform=iOS,name=Green’s iPhone" -only-testing DBDemoUITests/DBDemoUITests/testExample -allowProvisioningUpdates 2>&1 | tee $csvPath+"prereq.txt"
  exit
fi


echo python $startSamplingScript -o $csvPath -t $testTime &


python $startSamplingScript -o $csvPath -t $((testTime*60))  &
echo "Sampling start time:  $(date '+%T')" 2>&1 | tee $csvPath+"sampleStartTime.txt"

#Uncomment one of the following three conditions:

### ### ### ### ### ###
### CONDITION NO 1 ###
### ### ### ### ### ###
### Keep these line uncommented for benchmarks execution ###
#echo xcodebuild test -project $xPath -scheme DBDemo -destination "platform=iOS,name=Green’s iPhone" -only-testing DBDemoUITests/DBDemoUITests/testExample
#xcodebuild test -project $xPath -scheme DBDemo -destination "platform=iOS,name=Green’s iPhone" -only-testing DBDemoUITests/DBDemoUITests/testExample -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
#### CONDITION ENDS ####

### ### ### ### ### ###
### CONDITION NO 2 ###
### ### ### ### ### ###
### Keep these lines uncommented for a test case of an CartrackTechChallenge xcodeproject execution ###
### echo xcodebuild test -workspace $xPath -scheme CartrackTechChallenge -destination "platform=iOS,name=Green’s iPhone" -only-testing CartrackTechChallengeTests -allowProvisioningUpdates
### xcodebuild test -workspace $xPath -scheme CartrackTechChallenge -destination "platform=iOS,name=Green’s iPhone" -only-testing CartrackTechChallengeTests -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
#### CONDITION ENDS ####

### ### ### ### ### ###
### CONDITION NO 2 ###
### ### ### ### ### ###
### Keep these lines uncommented for a test case of an InventarioSeguro xcodeproject execution ###
echo xcodebuild test -workspace $xPath -scheme InventarioSeguro -destination "platform=iOS,name=Green’s iPhone" -only-testing InventarioSeguroUITests -allowProvisioningUpdates
xcodebuild test -workspace $xPath -scheme InventarioSeguro -destination "platform=iOS,name=Green’s iPhone" -only-testing InventarioSeguroUITests -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
#### CONDITION ENDS ####

### ### ### ### ### ###
### CONDITION NO 4 ###
### ### ### ### ### ###
### Keep these lines uncommented for a test case of an xcode workspace execution ###
#xcodebuild test -project $xPath -scheme $scheme -destination "platform=iOS,name=Green’s iPhone" -only-testing $test_location -allowProvisioningUpdates 2>&1 | tee $csvPath+"xcode.txt"
#### CONDITION ENDS ####


sleep 2
pkill -9 -f /Users/greenali/Desktop/greenminer/monsoon-0.1.88/startSamplingToFileArgs.py

# Running extra python script in the next line to throw an error and get serial port rid of the parallel process
echo "Flush: "python $startSamplingScript -o $csvPath+"err.csv" -t 1
python $startSamplingScript -o $csvPath+"err.csv" -t 1 > /dev/null 2>&1
# "aggregateResults.py -s <startTimePath> -x <xCodeBuildPath> -o <outputCsvPath> -e <energyCsv>"
echo python3 aggregateResults.py -s $csvPath+"sampleStartTime.txt" -x $csvPath+"xcode.txt" -o $csvPath -e $energyFile
python3 aggregateResults.py -s $csvPath+"sampleStartTime.txt" -x $csvPath+"xcode.txt" -o $csvPath -e $energyFile

rm $csvPath+"err.csv"
echo "exiting the script"


exit
