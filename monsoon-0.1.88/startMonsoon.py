import Monsoon.HVPM as HVPM
import Monsoon.Operations as op
import Monsoon.sampleEngine as sampleEngine
import sys

print(sys.version)
Mon = HVPM.Monsoon()
Mon.setup_usb()
print('Serial Number:' , Mon.getSerialNumber())
Mon.setVout(4.2)
