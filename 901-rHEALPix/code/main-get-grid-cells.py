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

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
import json

from rHEALPix_grid_extent import get_extent_point2grid

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
shp_point_extent_planar = "extent-point-rHEALPix-planar.shp"

dict_rhealpix_grid_extent = get_extent_point2grid(
    shp_point_extent_planar = shp_point_extent_planar,
    grid_resolution         = resolution
    )
print("\ndict_rhealpix_grid_extent")
print(   dict_rhealpix_grid_extent )

json_object = json.dumps(
    obj    = dict_rhealpix_grid_extent,
    indent = 4
    )
 
# Writing to sample.json
with open("extent-grid-rHEALPix-planar.json", "w") as outfile:
    outfile.write(json_object)

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # fhd_extent = open('extent.json')
# # dct_extent = json.load(fhd_extent)

# # print( "dct_extent['xmin'][0] = " + str(dct_extent['xmin'][0]) )
# # print( "dct_extent['xmax'][0] = " + str(dct_extent['xmax'][0]) ) 

# # print( "dct_extent['ymin'][0] = " + str(dct_extent['ymin'][0]) )
# # print( "dct_extent['ymax'][0] = " + str(dct_extent['ymax'][0]) )

# gdf_extent_rhealpixplane = geopandas.read_file("my-extent-rHEALPix-plane.shp") 

# gdf_extent_rhealpixplane['lon'] = gdf_extent_rhealpixplane['geometry'].x
# gdf_extent_rhealpixplane['lat'] = gdf_extent_rhealpixplane['geometry'].y

# print("\ngdf_extent_rhealpixplane:")
# print(   gdf_extent_rhealpixplane  )

# gdf_extent_epsg4326 = geopandas.read_file("my-extent-EPSG-4326.shp") 

# gdf_extent_epsg4326['lon'] = gdf_extent_epsg4326['geometry'].x
# gdf_extent_epsg4326['lat'] = gdf_extent_epsg4326['geometry'].y

# print("\ngdf_extent_epsg4326:")
# print(   gdf_extent_epsg4326  )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# WGS84_minus50 = Ellipsoid(a=WGS84_A, f=WGS84_F, radians=False, lon_0=-50)
# print("\nWGS84_minus50:")
# print(   WGS84_minus50  )

# rHEALPixCanada = RHEALPixDGGS(
#     ellipsoid    = WGS84_minus50,
#     north_square = 0,
#     south_square = 0,
#     N_side       = 3
#     )
# print("\ntype(rHEALPixCanada):")
# print(   type(rHEALPixCanada)  )
# print("\nrHEALPixCanada:")
# print(   rHEALPixCanada  )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# cell_xmin_ymin = rHEALPixCanada.cell_from_point(
#     resolution = int(resolution),
#     p          = (
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymin']['lon'].iloc[0],
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymin']['lat'].iloc[0]
#         ),
#     plane = False
#     )
# print("\ncell_xmin_ymin:")
# print(   cell_xmin_ymin  )

# cell_xmax_ymin = rHEALPixCanada.cell_from_point(
#     resolution = int(resolution),
#     p          = (
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lon'].iloc[0],
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lat'].iloc[0]
#         ),
#     plane = False
#     )
# print("\ncell_xmax_ymin:")
# print(   cell_xmax_ymin  )

# cell_xmax_ymax = rHEALPixCanada.cell_from_point(
#     resolution = int(resolution),
#     p          = (
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymax']['lon'].iloc[0],
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymax']['lat'].iloc[0]
#         ),
#     plane = False
#     )
# print("\ncell_xmax_ymax:")
# print(   cell_xmax_ymax  )

# cell_xmin_ymax = rHEALPixCanada.cell_from_point(
#     resolution = int(resolution),
#     p          = (
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymax']['lon'].iloc[0],
#         gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymax']['lat'].iloc[0]
#         ),
#     plane = False
#     )
# print("\ncell_xmin_ymin:")
# print(   cell_xmin_ymin  )

# corner_cells = [
#     cell_xmin_ymin,
#     cell_xmax_ymin,
#     cell_xmax_ymax,
#     cell_xmin_ymax
#     ]

# print("\ncorner_cells:")
# print(   corner_cells  )

# gdf_corner_cells = geopandas.GeoDataFrame(
#     columns = ['cellID','geometry'],
#     crs     = "EPSG:4326"
#     )

# i = 0
# for myCell in corner_cells:
#     myData = {
#         'cellID':   str(myCell),
#         'geometry': LineString(myCell.boundary(plane = False))
#         }
#     myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
#     gdf_corner_cells = pandas.concat([gdf_corner_cells, myRow])
#     i = i + 1

# print("\ngdf_corner_cells:")
# print(   gdf_corner_cells  )

# shp_output = 'rHEALPix-corner-cells-r' + '{:03d}'.format(int(resolution)) + '.shp'
# gdf_corner_cells.to_file(
#     filename = shp_output,
#     driver   = 'ESRI Shapefile'
#     )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# parallel_cells = rHEALPixCanada.cells_from_parallel(
#     resolution = int(resolution),
#     phi        = gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lat'].iloc[0], # gdf_extent_epsg4326['lat'].min(),
#     lam_min    = gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lon'].iloc[0], # gdf_extent_epsg4326['lon'].min(),
#     lam_max    = gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymax']['lon'].iloc[0]  # gdf_extent_epsg4326['lon'].max()
#     )
# print("\nparallel_cells:")
# print(   parallel_cells  )

# meridian_cells = rHEALPixCanada.cells_from_meridian(
#     resolution = int(resolution),
#     lam        = gdf_extent_epsg4326['lon'].min(),
#     phi_min    = gdf_extent_epsg4326['lat'].min(),
#     phi_max    = gdf_extent_epsg4326['lat'].max(),
#     )
# print("\nmeridian_cells:")
# print(   meridian_cells  )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # corner_upper_left  = (
# #     gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymax']['lon'].iloc[0],
# #     gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmin_ymax']['lat'].iloc[0]
# #     )

# # corner_lower_right = (
# #     gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lon'].iloc[0],
# #     gdf_extent_epsg4326.loc[gdf_extent_epsg4326['label'] == 'xmax_ymin']['lat'].iloc[0]
# #     )

# corner_upper_left  = ( gdf_extent_epsg4326['lon'].min() , gdf_extent_epsg4326['lat'].max() )
# corner_lower_right = ( gdf_extent_epsg4326['lon'].max() , gdf_extent_epsg4326['lat'].min() )

# print("\ncorner_upper_left (EPSG:4326):")
# print(   corner_upper_left  )

# print("\ncorner_lower_right (EPSG:4326):")
# print(   corner_lower_right  )

# corner_upper_left  = ( gdf_extent_rhealpixplane['lon'].min() , gdf_extent_rhealpixplane['lat'].max() )
# corner_lower_right = ( gdf_extent_rhealpixplane['lon'].max() , gdf_extent_rhealpixplane['lat'].min() )

# print("\ncorner_upper_left (rHEALPix plane):")
# print(   corner_upper_left  )

# print("\ncorner_lower_right (rHEALPix plane):")
# print(   corner_lower_right  )

# covering_cells = rHEALPixCanada.cells_from_region(
#     resolution = int(resolution),
#     ul         = corner_upper_left,
#     dr         = corner_lower_right,
#     plane      = True # False
#     )
# print("\ncovering_cells:")
# print(   covering_cells  )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# gdf_parallel_cells = geopandas.GeoDataFrame(
#     columns = ['cellID','geometry'],
#     crs     = "EPSG:4326"
#     )

# print("\ngdf_parallel_cells:")
# print(   gdf_parallel_cells  )

# i = 0
# for myCell in parallel_cells:
#     myData = {
#         'cellID':   str(myCell),
#         'geometry': LineString(myCell.boundary(plane = False))
#         }
#     myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
#     gdf_parallel_cells = pandas.concat([gdf_parallel_cells, myRow])
#     i = i + 1

# print("\ngdf_parallel_cells:")
# print(   gdf_parallel_cells  )

# shp_output = 'rHEALPix-parallel-cells-r' + '{:03d}'.format(int(resolution)) + '.shp'
# gdf_parallel_cells.to_file(
#     filename = shp_output,
#     driver   = 'ESRI Shapefile'
#     )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# gdf_meridian_cells = geopandas.GeoDataFrame(
#     columns = ['cellID','geometry'],
#     crs     = "EPSG:4326"
#     )

# print("\ngdf_meridian_cells:")
# print(   gdf_meridian_cells  )

# i = 0
# for myCell in meridian_cells:
#     myData = {
#         'cellID':   str(myCell),
#         'geometry': LineString(myCell.boundary(plane = False))
#         }
#     myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
#     gdf_meridian_cells = pandas.concat([gdf_meridian_cells, myRow])
#     i = i + 1

# print("\ngdf_meridian_cells:")
# print(   gdf_meridian_cells  )

# shp_output = 'rHEALPix-meridian-cells-r' + '{:03d}'.format(int(resolution)) + '.shp'
# gdf_meridian_cells.to_file(
#     filename = shp_output,
#     driver   = 'ESRI Shapefile'
#     )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# gdf_covering_cells = geopandas.GeoDataFrame(
#     columns = ['cellID','geometry'],
#     crs     = "EPSG:4326"
#     )

# print("\ngdf_covering_cells:")
# print(   gdf_covering_cells  )

# i = 0
# for list_cells in covering_cells:
#     for myCell in list_cells:
#         myData = {
#             'cellID':   str(myCell),
#             'geometry': LineString(myCell.boundary(plane = False))
#             }
#         myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
#         gdf_covering_cells = pandas.concat([gdf_covering_cells, myRow])
#         i = i + 1

# print("\ngdf_covering_cells:")
# print(   gdf_covering_cells  )

# shp_output = 'rHEALPix-covering-cells-r' + '{:03d}'.format(int(resolution)) + '.shp'
# gdf_covering_cells.to_file(
#     filename = shp_output,
#     driver   = 'ESRI Shapefile'
#     )

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# # my_resolution  = 11;

# # grid_latitudes = rHEALPixCanada.cell_latitudes(
# #     resolution = my_resolution,
# #     phi_min    = dct_extent['ymin'][0],
# #     phi_max    = dct_extent['ymax'][0],
# #     nucleus    = True,
# #     plane      = False
# #     )

# # print("len(grid_latitudes)")
# # print( len(grid_latitudes) )

# # cells_lower_parellel = rHEALPixCanada.cells_from_parallel(
# #     resolution = my_resolution,
# #     phi        = dct_extent['ymin'][0],
# #     lam_min    = dct_extent['xmin'][0],
# #     lam_max    = dct_extent['xmax'][0]
# #     )

# # print("cells_lower_parellel")
# # print(len([str(cell) for cell in cells_lower_parellel]))

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
