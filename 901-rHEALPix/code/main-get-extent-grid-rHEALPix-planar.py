#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat, pandas, geopandas

dir_data            = os.path.realpath(sys.argv[1])
dir_code            = os.path.realpath(sys.argv[2])
dir_output          = os.path.realpath(sys.argv[3])
google_drive_folder = sys.argv[4]
resolution          = float(sys.argv[5])

if not os.path.exists(dir_output):
    os.makedirs(dir_output)

os.chdir(dir_output)

myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( "\n" + myTime + "\n" )

print( "\ndir_data: "            + dir_data            )
print( "\ndir_code: "            + dir_code            )
print( "\ndir_output: "          + dir_output          )
print( "\ngoogle_drive_folder: " + google_drive_folder )
print( "\nresolution: "          + str(resolution)     )

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

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
import json

from rHEALPix_grid_extent import get_extent_point2grid

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
shp_point_extent_planar = "extent-point-rHEALPix-planar.shp"

dict_rhealpix_grid_extent = get_extent_point2grid(
    shp_point_extent_planar = shp_point_extent_planar,
    grid_resolution         = resolution
    )
print("\ndict_rhealpix_grid_extent")
print(   dict_rhealpix_grid_extent )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
json_object = json.dumps(
    obj    = dict_rhealpix_grid_extent['raster_extent'],
    indent = 4
    )
 
with open("extent-grid-rHEALPix-planar.json", "w") as outfile:
    outfile.write(json_object)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
gdf_boundary_centroids = dict_rhealpix_grid_extent['boundary_centroids']

shp_output = 'rHEALPix-planar-boundary-centroids-r' + '{:03d}'.format(int(resolution)) + '.shp'
gdf_boundary_centroids.to_file(
    filename = shp_output,
    driver   = 'ESRI Shapefile'
    )

shp_output = 'epsg4326-boundary-centroids-r' + '{:03d}'.format(int(resolution)) + '.shp'
gdf_boundary_centroids = gdf_boundary_centroids.to_crs(epsg = 4326)
gdf_boundary_centroids.to_file(
    filename = shp_output,
    driver   = 'ESRI Shapefile'
    )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
gdf_bounding_vertices = dict_rhealpix_grid_extent['bounding_vertices']

shp_output = 'rHEALPix-planar-bounding-vertices-r' + '{:03d}'.format(int(resolution)) + '.shp'
gdf_bounding_vertices.to_file(
    filename = shp_output,
    driver   = 'ESRI Shapefile'
    )

shp_output = 'epsg4326-bounding-vertices-r' + '{:03d}'.format(int(resolution)) + '.shp'
gdf_bounding_vertices = gdf_bounding_vertices.to_crs(epsg = 4326)
gdf_bounding_vertices.to_file(
    filename = shp_output,
    driver   = 'ESRI Shapefile'
    )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
