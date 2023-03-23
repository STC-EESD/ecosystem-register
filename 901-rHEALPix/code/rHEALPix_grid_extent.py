
import stat, pandas, geopandas, pyproj.crs

from rhealpixdggs.ellipsoids import *
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs
from geopandas               import GeoDataFrame
from shapely.geometry        import Point, Polygon, LinearRing, LineString

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
rHEALPix_proj4string = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50"
rHEALPix_crs_obj     = pyproj.crs.CRS(rHEALPix_proj4string)

WGS84_minus50 = Ellipsoid(
    a       = WGS84_A,
    f       = WGS84_F,
    radians = False,
    lon_0   = -50
    )
print("\nWGS84_minus50:")
print(   WGS84_minus50  )

rHEALPixCanada = RHEALPixDGGS(
    ellipsoid    = WGS84_minus50,
    north_square = 0,
    south_square = 0,
    N_side       = 3
    )
print("\ntype(rHEALPixCanada):")
print(   type(rHEALPixCanada)  )
print("\nrHEALPixCanada:")
print(   rHEALPixCanada  )

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
def get_extent_point2grid(
    shp_point_extent_planar,
    grid_resolution = 8
    ):

    thisFunctionName = "get_extent_point2grid"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_corner_cells_planar = get_corner_cells_planar(
        shp_point_extent_planar = shp_point_extent_planar,
        grid_resolution         = grid_resolution
        )
    print("\ngdf_corner_cells_planar")
    print(   gdf_corner_cells_planar )

    gdf_corner_cells_epsg4326 = gdf_corner_cells_planar.to_crs(epsg = 4326)
    print("\ngdf_corner_cells_epsg4326")
    print(   gdf_corner_cells_epsg4326 )

    shp_output = 'epsg4326-corner-cells-r' + '{:03d}'.format(int(grid_resolution)) + '.shp'
    gdf_corner_cells_epsg4326.to_file(
        filename = shp_output,
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    dict_covering_cells_planar = get_covering_cells_planar(
        shp_point_extent_planar = shp_point_extent_planar,
        grid_resolution         = grid_resolution
        )
    print("\ndict_covering_cells_planar")
    print(   dict_covering_cells_planar )

    if grid_resolution < 9:
        gdf_covering_cells_planar = dict_covering_cells_planar['covering_cells_planar']
        print("\ngdf_covering_cells_planar")
        print(   gdf_covering_cells_planar )
        gdf_covering_cells_epsg4326 = gdf_covering_cells_planar.to_crs(epsg = 4326)
        print("\ngdf_covering_cells_epsg4326")
        print(   gdf_covering_cells_epsg4326 )
        shp_output = 'epsg4326-covering-cells-r' + '{:03d}'.format(int(grid_resolution)) + '.shp'
        gdf_covering_cells_epsg4326.to_file(
            filename = shp_output,
            driver   = 'ESRI Shapefile'
            )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    dict_output = {
        'boundary_centroids': dict_covering_cells_planar['boundary_centroids'],
        'bounding_vertices':  dict_covering_cells_planar['bounding_vertices' ],
        'raster_extent':      dict_covering_cells_planar['raster_extent'     ]
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( dict_output )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
def get_covering_cells_planar(
    shp_point_extent_planar,
    grid_resolution = 8
    ):

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_extent_planar = geopandas.read_file(shp_point_extent_planar)

    gdf_extent_planar['x'] = gdf_extent_planar['geometry'].x
    gdf_extent_planar['y'] = gdf_extent_planar['geometry'].y

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    planar_xmin = gdf_extent_planar['x'].min()
    planar_xmax = gdf_extent_planar['x'].max()

    planar_ymin = gdf_extent_planar['y'].min()
    planar_ymax = gdf_extent_planar['y'].max()

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    corner_upper_left  = ( planar_xmin , planar_ymax )
    corner_lower_right = ( planar_xmax , planar_ymin )

    print("\ncorner_upper_left (rHEALPix plane):")
    print(   corner_upper_left  )

    print("\ncorner_lower_right (rHEALPix plane):")
    print(   corner_lower_right  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    covering_cells = rHEALPixCanada.cells_from_region(
        resolution = int(grid_resolution),
        ul         = corner_upper_left,
        dr         = corner_lower_right,
        plane      = True
        )
    print("\ncovering_cells:")
    print(   covering_cells  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_covering_cells = None
    if grid_resolution < 9:
        gdf_covering_cells = geopandas.GeoDataFrame(
            columns = ['cellID','geometry'],
            crs     = rHEALPix_crs_obj
            )

        print("\ngdf_covering_cells:")
        print(   gdf_covering_cells  )
        i = 0
        for list_cells in covering_cells:
            for myCell in list_cells:
                myData = {
                    'cellID':   str(myCell),
                    'geometry': LineString(myCell.boundary(plane = True))
                    }
                myRow = GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
                gdf_covering_cells = pandas.concat([gdf_covering_cells, myRow])
                i = i + 1
        print("\ngdf_covering_cells:")
        print(   gdf_covering_cells  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_boundary_centroids = geopandas.GeoDataFrame(
        columns = ['cellID','geometry'],
        crs     = rHEALPix_crs_obj
        )

    i = 0
    for myCell in covering_cells[0]:
        myData = {
            'cellID':   str(myCell),
            'geometry': Point(myCell.centroid(plane = True))
            }
        myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
        gdf_boundary_centroids = pandas.concat([gdf_boundary_centroids,myRow])
        i = i + 1

    for j in range(0,len(covering_cells)):
        myCell = covering_cells[j][0]
        myData = {
            'cellID':   str(myCell),
            'geometry': Point(myCell.centroid(plane = True))
            }
        myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
        gdf_boundary_centroids = pandas.concat([gdf_boundary_centroids,myRow])
        i = i + 1

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_boundary_cells = geopandas.GeoDataFrame(
        columns = ['cellID','geometry'],
        crs     = rHEALPix_crs_obj
        )

    i = 0
    for myCell in covering_cells[0]:
        myData = {
            'cellID':   str(myCell),
            'geometry': LineString(myCell.boundary(plane = True))
            }
        myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
        gdf_boundary_cells = pandas.concat([gdf_boundary_cells,myRow])
        i = i + 1

    for j in range(0,len(covering_cells)):
        myCell = covering_cells[j][0]
        myData = {
            'cellID':   str(myCell),
            'geometry': LineString(myCell.boundary(plane = True))
            }
        myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
        gdf_boundary_cells = pandas.concat([gdf_boundary_cells,myRow])
        i = i + 1

    gdf_boundary_cells['points'] = gdf_boundary_cells.apply(lambda x: [y for y in x['geometry'].coords], axis = 1)

    print("\ngdf_boundary_cells")
    print(   gdf_boundary_cells )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_vertices = geopandas.GeoDataFrame(
        columns = ['cellID','vertexID','geometry'],
        crs     = rHEALPix_crs_obj
        )

    cumul_n_vertices = 0
    for i in range(0,gdf_boundary_cells.shape[0]):
        temp_n_vertices = len(gdf_boundary_cells['points'][i])
        tempDF  = pandas.DataFrame({
            'cellID':   [gdf_boundary_cells['cellID'][i] for j in range(0,temp_n_vertices)],
            'vertexID': [j                               for j in range(0,temp_n_vertices)]
            })
        tempGDF = GeoDataFrame(
            data     = tempDF,
            geometry = [Point(x) for x in gdf_boundary_cells['points'][i]],
            crs      = rHEALPix_crs_obj
            )
        gdf_vertices = pandas.concat([gdf_vertices,tempGDF])
        cumul_n_vertices = cumul_n_vertices + temp_n_vertices

    gdf_vertices = gdf_vertices.set_index([pandas.Series([i for i in range(0,gdf_vertices.shape[0])])])

    gdf_vertices['x'] = gdf_vertices['geometry'].x
    gdf_vertices['y'] = gdf_vertices['geometry'].y

    print("\ngdf_vertices")
    print(   gdf_vertices )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_bounding_vertices = geopandas.GeoDataFrame(
        data = pandas.DataFrame({
            'label': ['xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax']
            }),
        geometry = [
            Point( gdf_vertices['x'].min() , gdf_vertices['y'].min() ),
            Point( gdf_vertices['x'].max() , gdf_vertices['y'].min() ),
            Point( gdf_vertices['x'].max() , gdf_vertices['y'].max() ),
            Point( gdf_vertices['x'].min() , gdf_vertices['y'].max() )
            ],
        crs = rHEALPix_crs_obj
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    dict_output = {
        'covering_cells_planar': gdf_covering_cells,
        'boundary_centroids':    gdf_boundary_centroids,
        'bounding_vertices':     gdf_bounding_vertices,
        'raster_extent': {
            'proj4string': rHEALPix_proj4string,
            'resolution':  int(grid_resolution),
            'xmin':        gdf_vertices['x'].min(),
            'xmax':        gdf_vertices['x'].max(),
            'ymin':        gdf_vertices['y'].min(),
            'ymax':        gdf_vertices['y'].max(),
            'nrows':       len(covering_cells),
            'ncols':       len(covering_cells[0])
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( dict_output )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
def get_corner_cells_planar(
    shp_point_extent_planar,
    grid_resolution = 8
    ):

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_extent_planar = geopandas.read_file(shp_point_extent_planar)

    gdf_extent_planar['x'] = gdf_extent_planar['geometry'].x
    gdf_extent_planar['y'] = gdf_extent_planar['geometry'].y

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    planar_xmin = gdf_extent_planar['x'].min()
    planar_xmax = gdf_extent_planar['x'].max()

    planar_ymin = gdf_extent_planar['y'].min()
    planar_ymax = gdf_extent_planar['y'].max()

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cell_xmin_ymin = rHEALPixCanada.cell_from_point(
        resolution = int(grid_resolution),
        p          = (planar_xmin,planar_ymin),
        plane      = True
        )
    print("\ncell_xmin_ymin:")
    print(   cell_xmin_ymin  )

    cell_xmax_ymin = rHEALPixCanada.cell_from_point(
        resolution = int(grid_resolution),
        p          = (planar_xmax,planar_ymin),
        plane      = True
        )
    print("\ncell_xmax_ymin:")
    print(   cell_xmax_ymin  )

    cell_xmax_ymax = rHEALPixCanada.cell_from_point(
        resolution = int(grid_resolution),
        p          = (planar_xmax,planar_ymax),
        plane      = True
        )
    print("\ncell_xmax_ymax:")
    print(   cell_xmax_ymax  )

    cell_xmin_ymax = rHEALPixCanada.cell_from_point(
        resolution = int(grid_resolution),
        p          = (planar_xmin,planar_ymax),
        plane      = True
        )
    print("\ncell_xmin_ymax:")
    print(   cell_xmin_ymax  )

    corner_cells = [
        cell_xmin_ymin,
        cell_xmax_ymin,
        cell_xmax_ymax,
        cell_xmin_ymax
        ]

    print("\ncorner_cells:")
    print(   corner_cells  )

    gdf_corner_cells = geopandas.GeoDataFrame(
        columns = ['cellID','geometry'],
        crs     = rHEALPix_crs_obj
        )

    i = 0
    for myCell in corner_cells:
        myData = {
            'cellID':   str(myCell),
            'geometry': LineString(myCell.boundary(plane = True))
            }
        myRow = GeoDataFrame(index = [i], data = myData, crs = rHEALPix_crs_obj)
        gdf_corner_cells = pandas.concat([gdf_corner_cells, myRow])
        i = i + 1

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( gdf_corner_cells )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
# def get_point_extent(
#     shp_rhealpix_point_extent
#     ):

#     gdf_extent_planar = geopandas.read_file(shp_rhealpix_point_extent) 

#     gdf_extent_planar['lon'] = gdf_extent_planar['geometry'].x
#     gdf_extent_planar['lat'] = gdf_extent_planar['geometry'].y

#     print("\ngdf_extent_planar:")
#     print(   gdf_extent_planar  )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
