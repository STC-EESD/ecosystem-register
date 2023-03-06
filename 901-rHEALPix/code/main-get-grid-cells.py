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
import json

from rhealpixdggs.ellipsoids import *  
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
fhd_extent = open('extent.json')
dct_extent = json.load(fhd_extent)

print( "dct_extent['xmin'][0] = " + str(dct_extent['xmin'][0]) )
print( "dct_extent['xmax'][0] = " + str(dct_extent['xmax'][0]) ) 

print( "dct_extent['ymin'][0] = " + str(dct_extent['ymin'][0]) )
print( "dct_extent['ymax'][0] = " + str(dct_extent['ymax'][0]) )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
WGS84_minus50 = Ellipsoid(a=WGS84_A, f=WGS84_F, radians=False, lon_0=-50)
print("WGS84_minus50:")
print( WGS84_minus50  )

rHEALPixCanada = RHEALPixDGGS(
    ellipsoid    = WGS84_minus50,
    north_square = 0,
    south_square = 0,
    N_side       = 3
    )
print("type(rHEALPixCanada):")
print( type(rHEALPixCanada)  )
print("rHEALPixCanada:")
print( rHEALPixCanada  )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my_resolution  = 7;

grid_latitudes = rHEALPixCanada.cell_latitudes(
    resolution = my_resolution,
    phi_min    = dct_extent['ymin'][0],
    phi_max    = dct_extent['ymax'][0],
    nucleus    = True,
    plane      = False
    )

print("grid_latitudes")
print( grid_latitudes )

cells_lower_parellel = rHEALPixCanada.cells_from_parallel(
    resolution my_resolution,
    phi      = dct_extent['ymin'][0],
    lam_min  = dct_extent['xmin'][0],
    lam_max  = dct_extent['xmax'][0]
    )

print("cells_lower_parellel")
print( cells_lower_parellel )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
