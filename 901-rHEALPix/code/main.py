#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat

dir_data            = os.path.realpath(sys.argv[1])
dir_code            = os.path.realpath(sys.argv[2])
dir_output          = os.path.realpath(sys.argv[3])
google_drive_folder = sys.argv[4]

if not os.path.exists(dir_output):
    os.makedirs(dir_output)

os.chdir(dir_output)

myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( "\n" + myTime + "\n" )

print( "\ndir_data: "            + dir_data            )
print( "\ndir_code: "            + dir_code            )
print( "\ndir_output: "          + dir_output          )
print( "\ngoogle_drive_folder: " + google_drive_folder )

print( "\nos.environ.get('GEE_ENV_DIR'):")
print(    os.environ.get('GEE_ENV_DIR')  )

print( "\n### python module search paths:" )
for path in sys.path:
    print(path)

print("\n####################")

logging.basicConfig(filename='log.debug',level=logging.DEBUG)

##################################################
##################################################
# import seaborn (for improved graphics) if available
# import seaborn as sns

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
from rhealpixdggs.ellipsoids import *  
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
print("WGS84_A:" + str(WGS84_A))
print("WGS84_F:" + str(WGS84_F))
print("WGS84_E:" + str(WGS84_E))

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
ellps_1 = Ellipsoid(a=5, e=0.8) 
print(ellps_1)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
E = WGS84_ELLIPSOID 
print(E)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
rdggs = dggs.WGS84_003 
print(rdggs)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
WGS84_minus50 = Ellipsoid(a=WGS84_A, f=WGS84_F, radians=False, lon_0=-50)
print(WGS84_minus50)

rHEALPixCanada = RHEALPixDGGS(
    ellipsoid    = WGS84_minus50,
    north_square = 0,
    south_square = 0,
    N_side       = 3
    )
print(rHEALPixCanada)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
