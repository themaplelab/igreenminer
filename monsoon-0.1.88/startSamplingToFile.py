import Monsoon.HVPM as HVPM
import Monsoon.Operations as op
import Monsoon.sampleEngine as sampleEngine
import sys

print(sys.version)
Mon = HVPM.Monsoon()
Mon.setup_usb()
print('Serial Number:' , Mon.getSerialNumber())

HVengine = sampleEngine.SampleEngine(Mon)
#Output to CSV
HVengine.enableCSVOutput("../MonsoonOutput/StandardAPI_Navigation256m.csv")
#Turning off periodic console outputs.
HVengine.ConsoleOutput(True)

#Setting all channels enabled
HVengine.enableChannel(sampleEngine.channels.MainCurrent)
HVengine.enableChannel(sampleEngine.channels.MainVoltage)
HVengine.enableChannel(sampleEngine.channels.timeStamp)

#Setting trigger conditions
numSamples=sampleEngine.triggers.SAMPLECOUNT_INFINITE
HVengine.setStartTrigger(sampleEngine.triggers.GREATER_THAN,0)
HVengine.setStopTrigger(sampleEngine.triggers.GREATER_THAN,2000)
HVengine.setTriggerChannel(sampleEngine.channels.timeStamp)
   
#Actually start collecting samples
HVengine.startSampling(numSamples)

#Disable CSV Output
HVengine.disableCSVOutput()



