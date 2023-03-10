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
from test_EASE2 import test_ease_grid

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
test_ease_grid()

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# WGS84_minus50 = Ellipsoid(a=WGS84_A, f=WGS84_F, radians=False, lon_0=-50)
# print("WGS84_minus50:")
# print( WGS84_minus50  )

# rHEALPixCanada = RHEALPixDGGS(
#     ellipsoid    = WGS84_minus50,
#     north_square = 0,
#     south_square = 0,
#     N_side       = 3
#     )
# print("type(rHEALPixCanada):")
# print( type(rHEALPixCanada)  )
# print("rHEALPixCanada:")
# print( rHEALPixCanada  )

# myGrid0 = rHEALPixCanada.grid(resolution = 0)
# print("myGrid0:")
# print([str(x) for x in myGrid0])

# # myGrid = rHEALPixCanada.grid(resolution = 0)
# # myGrid = rHEALPixCanada.grid(resolution = 1)
# # myGrid = rHEALPixCanada.grid(resolution = 2)
# myGrid = rHEALPixCanada.grid(resolution = 3)
# # myGrid = rHEALPixCanada.grid(resolution = 4)

# i = 0
# myGDF = GeoDataFrame(columns=['cellID','geometry'])
# for myCell in myGrid:
#     myData = {
#         'cellID':   str(myCell),
#         'geometry': LineString(myCell.boundary(plane = False))
#         # 'geometry': Polygon(myCell.boundary(plane = False))
#         # 'geometry': LinearRing(myCell.boundary(plane = False))
#         }
#     myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
#     myGDF = pandas.concat([myGDF, myRow])
#     i = i + 1
# print("myGDF:")
# print( myGDF  )

# myGDF.to_file(
#     filename = 'myGrid.shp',
#     driver   = 'ESRI Shapefile'
#     )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
