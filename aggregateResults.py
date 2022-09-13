import sys, getopt, time, csv, os
import pandas as pd
from pathlib import Path

def cropOutputCsv(testStartedAfter_sec,testEndedAfter_sec,outputCsvPath,energyCsv):
    df = pd.read_csv(outputCsvPath)
    df = df.rename(columns={'Time(ms)': 'time', 'Main(mA)': 'main', 'Main Voltage(V)': 'volt'})
    df =  df[df.time > testStartedAfter_sec]
    df =  df[df.time < testEndedAfter_sec]
    totalTime = testEndedAfter_sec - testStartedAfter_sec
    print(totalTime)
    meanCurrent = df["main"].mean()/1000
    meanVolt = df["volt"].mean()
    totalEnergy = (meanCurrent   *  meanVolt) * totalTime
    print(totalEnergy)
    #/Users/abdulalib/Desktop/loopEnergy/Output/insertion/10000__1.csv
    testRun = outputCsvPath.split(".csv")[0].split("__")[1]
    print(testRun)
    temp = outputCsvPath.split("__")[0].split(os.sep) # get an array
    print(temp)
    benchmarkName = temp[len(temp)-1]
    #file,benchmark,testrun,energy,totaltime,current,voltage,teststarttime,testendtime
    df = pd.read_csv(energyCsv)
    print(df)
    new_row = {'file':outputCsvPath, 'benchmark':benchmarkName, 'testrun':testRun, 'energy':totalEnergy, 'totaltime':totalTime, 'current':meanCurrent, 'voltage':meanVolt, 'teststarttime':testStartedAfter_sec, 'testendtime':testEndedAfter_sec}
    print(new_row)
    df = df.append(new_row, ignore_index=True)
    df.to_csv(energyCsv, index=False)

def getStartTime(startTimePath):
    with open(startTimePath) as f:
        contents = f.read()
    list = contents.split(":  ")
    return list[1].strip()

def getTearDownFromXClog(lines):
    file_format = ".xcresult"
    for x in reversed(lines):
        if file_format in x:
            log_file_path = x.strip()
            print("log file path:")
            print(log_file_path)
            command = "mkdir temp"
            os.system(command)
            command = "xcparse logs " + log_file_path + " temp/"
            os.system(command)
            # recursively get all files in temp directory
            session_file_paths = list(Path(".").rglob("*Session*.log"))
            print("Session file path:")
            print(session_file_paths[0])
            with open(session_file_paths[0]) as f:
                log_lines = f.readlines()
                for log_line in reversed(log_lines):
                    substring = "Total time in activities:"
                    if substring in log_line:
                        tear_down = log_line.split(substring)[1].split("s")[0].strip()
                        command = "rm -rf temp"
                        os.system(command)
                        return tear_down

def getStartTCTime(xCodeBuildPath):
    overhead_substring = "Setting up automation session"
    substring = "0.00s Start Test"
    substring_teardown = "Tear Down"
    error_string = "Unable to launch"
    success_string = "** TEST SUCCEEDED **"
    multiple_tests_string = "Test Suite 'All tests' passed"
    multiple_test_start_string = "'All tests' started at "
    multiple_tests_teardown_string = "'All tests' passed at "
    multiple_tests = False

    with open(xCodeBuildPath) as f:
        lines = f.readlines()

    test_passed = False
    for x in reversed(lines):
        if success_string in x:
            test_passed = True
            break

    for x in reversed(lines):
        if multiple_tests_string in x:
            multiple_tests = True
            break

    if test_passed is False:
        return "Build Failure by Xcode"

    count = 0
    end_exist = False

    # Please note that overhead gets compromised in multiple tests, also the teardown is unknown, so the times are pretty inaccurate
    if multiple_tests is True:
        for line in lines:
            count = count + 1
            if multiple_test_start_string in line:
                start = line.split(multiple_test_start_string)[1].split(" ")[1].strip()
            if multiple_tests_teardown_string in line:
                end = lines[count].split(" in ")[1].split(" (")[0]
                end_exist = True
                break
        return start + "#" + end + "#" + str(0)

    for line in lines:
        if error_string in line:
            count = 0
            break
        if count==0 and (substring in line):
            count = count + 1
            start = line.split("=")[1].split("at ")[1].split(" ")[1].split('\n')[0].strip()
            continue
        if overhead_substring in line:
            overhead = line.split("=")[1].split("s")[0].strip()
        if substring_teardown in line:
            count = count + 1
            end = line.split("=")[1].split("s")[0].strip()
            end_exist = True
            break
    if count!=0 and end_exist:
        return start + "#" + end + "#" + overhead
    else:
        if test_passed:
            wait_string = "Wait for"
            wait_for_background_key = "Background"
            for x in reversed(lines):
                if wait_string in x:
                    # Check if first string that appears in reverse order has background in it or not
                    if wait_for_background_key not in x:
                        # This means that xcodebuild output on the terminal was premature even though the test case SUCCEEDED
                        # Now retrieve tear down time from the .xcresult file using library: brew install chargepoint/xcparse/xcparse
                        tear_down = getTearDownFromXClog(lines)
                        return start + "#" + tear_down + "#" + overhead
                    tear_down = x.split("=")[1].split("s")[0].strip()
                    return start + "#" + tear_down + "#" + overhead
        return "Build Failure by Xcode"


def main(argv):
    pathToFixIntroPairs = ''
    repositoryFolder = ''
    try:
      opts, args = getopt.getopt(argv,"hs:x:o::e:")
    except getopt.GetoptError as e:
      print("script.py -s <startTimePath> -x <xCodeBuildPath> -o <outputCsvPath> -e <energyCsv>")
      sys.exit(2)
    for opt, arg in opts:
      if opt == '-h':
         print("script.py -s <startTimePath> -x <xCodeBuildPath> -o <outputCsvPath> -e <energyCsv>")
         sys.exit()
      if opt == '-s':
         startTimePath = arg
      elif opt == '-x':
         xCodeBuildPath = arg
      elif opt == '-o':
         outputCsvPath = arg
      elif opt == '-e':
         energyCsv = arg
    print("startTimePath file is: " + startTimePath)
    print("xCodeBuildPath file is: " + xCodeBuildPath)
    print("outputCsvPath file is: " + outputCsvPath)
    print("energyCsv file is: " + energyCsv)

    try:
        with open(energyCsv, 'x') as f:
            f.write("file,benchmark,testrun,energy,totaltime,current,voltage,teststarttime,testendtime")
    except FileExistsError:
        print("Output file already exists.")

    startMonsoonTime = getStartTime(startTimePath).split(":")
    startMonsoonTime = int(startMonsoonTime[0])*3600 + int(startMonsoonTime[1])*60 + int(startMonsoonTime[2])
    print(startMonsoonTime)

    startEndTestCaseTime = getStartTCTime(xCodeBuildPath)
    start_end_overhead = startEndTestCaseTime.split("#") # 1: start, 2:end, 3:overhead
    startTestTime = start_end_overhead[0].split(":")
    startTestTime = int(startTestTime[0])*3600 + int(startTestTime[1])*60 + float(startTestTime[2])
    startTestTime = startTestTime + float(start_end_overhead[2])
    totalTestTime = start_end_overhead[1]

    print(startTestTime)
    print(totalTestTime)

    testStartedAfter_sec = startTestTime - startMonsoonTime
    testEndedAfter_sec = testStartedAfter_sec + float(totalTestTime) - float(start_end_overhead[2])

    print("Test Started After: ",testStartedAfter_sec)
    print("Test Ended After: ",testEndedAfter_sec)

    cropOutputCsv(testStartedAfter_sec,testEndedAfter_sec,outputCsvPath,energyCsv)

if __name__ == "__main__":
   main(sys.argv[1:])
