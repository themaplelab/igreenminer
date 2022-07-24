import sys, getopt, time, csv, os
import pandas as pd
from pathlib import Path

# USAGE: First fix loop then run on terminal:
# python3 aggregateResultsInFolder.py -p "/Users/greenali/Desktop/loopEnergy/Output/read/"

def main(argv):
    pathToFixIntroPairs = ''
    repositoryFolder = ''
    try:
      opts, args = getopt.getopt(argv,"hp:")
    except getopt.GetoptError as e:
      print("script.py -p <folder_path>")
      sys.exit(2)
    for opt, arg in opts:
      if opt == '-h':
         print("script.py -p <folder_path>")
         sys.exit()
      if opt == '-p':
         folder_path = arg
    print("folder_path file is: " + folder_path)

    i = 100000
    while i <= 100000:
      j=1
      while j <= 10:
          token = str(i)+"__"+str(j)
          benchmark = token.strip()
          start_file = folder_path + "/" + benchmark + ".csv+sampleStartTime.txt"
          xcode_log_file = folder_path + "/" + benchmark + ".csv+xcode.txt"
          energy_file = folder_path + "/" + benchmark + ".csv"
          output_file = folder_path + "/TotalEnergy.csv"
          command = "python3 aggregateResults.py -s " + start_file + " -x " + xcode_log_file + " -o " + energy_file + " -e " + output_file
          print(command)
          os.system(command)
          j = j+1
      i *= 10


if __name__ == "__main__":
   main(sys.argv[1:])
