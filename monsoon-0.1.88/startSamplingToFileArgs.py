import Monsoon.HVPM as HVPM
import Monsoon.Operations as op
import Monsoon.sampleEngine as sampleEngine
import sys, getopt

def main(argv):
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,'ho:t:',['output'])
   except getopt.GetoptError:
      print 'test.py -o <outputEnergyCsvFilePath>'
      print 'test.py -t <testTimeSeconds>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -o <outputEnergyCsvFilePath>'
         print 'test.py -t <testTimeSeconds>'
         sys.exit()
      if opt == '-t':
         time = arg
      elif opt in ("-o", "--output"):
         outputfile = arg
   print 'Output file is "', outputfile
   startSample(outputfile, time)

def startSample(outputfile, time):
    print(sys.version)
    Mon = HVPM.Monsoon()
    Mon.setup_usb()
    print('Serial Number:' , Mon.getSerialNumber())

    HVengine = sampleEngine.SampleEngine(Mon)
    #Output to CSV
    HVengine.enableCSVOutput(outputfile)
    #Turning off periodic console outputs.
    HVengine.ConsoleOutput(True)

    #Setting all channels enabled
    HVengine.enableChannel(sampleEngine.channels.MainCurrent)
    HVengine.enableChannel(sampleEngine.channels.MainVoltage)
    HVengine.enableChannel(sampleEngine.channels.timeStamp)

    #Setting trigger conditions
    numSamples=sampleEngine.triggers.SAMPLECOUNT_INFINITE
    #Start when we exceed 0s
    HVengine.setStartTrigger(sampleEngine.triggers.GREATER_THAN,0)
    #Stop when we exceed $time seconds
    print 'Time in seconds is ', time
    HVengine.setStopTrigger(sampleEngine.triggers.GREATER_THAN,int(time))
    #Start and stop judged by the main channel.
    HVengine.setTriggerChannel(sampleEngine.channels.timeStamp)

    #Actually start collecting samples
    HVengine.startSampling(numSamples)

    #Disable CSV Output
    HVengine.disableCSVOutput()

    #/Users/abdulalib/Desktop/greenminer/iOS/LocationBenchmarks/RegionalAPI/Journal.xcodeproj
    #/Users/abdulalib/Desktop/greenminer/iOS/RunLocationBenchmark/data/regionalAPI.csv
    #Output file is " /Users/abdulalib/Desktop/greenminer/iOS/RunLocationBenchmark/data/regionalAPI.csv


if __name__ == "__main__":
   main(sys.argv[1:])
