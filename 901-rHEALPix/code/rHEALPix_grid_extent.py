
import stat, pandas, geopandas, pyproj.crs

from rhealpixdggs.ellipsoids import *
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs
from geopandas               import GeoDataFrame
from shapely.geometry        import Polygon, LinearRing, LineString


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
my_rHEALPix_crs = pyproj.crs.CRS("+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50")

WGS84_minus50 = Ellipsoid(a=WGS84_A, f=WGS84_F, radians=False, lon_0=-50)
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

    shp_output = 'rHEALPix-corner-cells-r' + '{:03d}'.format(int(grid_resolution)) + '.shp'
    gdf_corner_cells_epsg4326.to_file(
        filename = shp_output,
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_covering_cells_planar = get_covering_cells_planar(
        shp_point_extent_planar = shp_point_extent_planar,
        grid_resolution         = grid_resolution
        )

    gdf_covering_cells_epsg4326 = gdf_covering_cells_planar.to_crs(epsg = 4326)

    print("\ngdf_covering_cells_epsg4326")
    print(   gdf_covering_cells_epsg4326 )

    shp_output = 'rHEALPix-covering-cells-r' + '{:03d}'.format(int(grid_resolution)) + '.shp'
    gdf_covering_cells_epsg4326.to_file(
        filename = shp_output,
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
def get_covering_cells_planar(
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
    corner_upper_left  = ( planar_xmin , planar_ymax )
    corner_lower_right = ( planar_xmax , planar_ymin )

    print("\ncorner_upper_left (rHEALPix plane):")
    print(   corner_upper_left  )

    print("\ncorner_lower_right (rHEALPix plane):")
    print(   corner_lower_right  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    covering_cells = rHEALPixCanada.cells_from_region(
        resolution = int(grid_resolution),
        ul         = corner_upper_left,
        dr         = corner_lower_right,
        plane      = True
        )
    print("\ncovering_cells:")
    print(   covering_cells  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    gdf_covering_cells = geopandas.GeoDataFrame(
        columns = ['cellID','geometry'],
        crs     = my_rHEALPix_crs
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
            myRow = GeoDataFrame(index = [i], data = myData, crs = my_rHEALPix_crs)
            gdf_covering_cells = pandas.concat([gdf_covering_cells, myRow])
            i = i + 1

    print("\ngdf_covering_cells:")
    print(   gdf_covering_cells  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( gdf_covering_cells )


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
        crs     = my_rHEALPix_crs
        )

    i = 0
    for myCell in corner_cells:
        myData = {
            'cellID':   str(myCell),
            'geometry': LineString(myCell.boundary(plane = True))
            }
        myRow = GeoDataFrame(index = [i], data = myData, crs = my_rHEALPix_crs)
        gdf_corner_cells = pandas.concat([gdf_corner_cells, myRow])
        i = i + 1

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( gdf_corner_cells )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
def get_point_extent(
    shp_rhealpix_point_extent
    ):

    gdf_extent_planar = geopandas.read_file(shp_rhealpix_point_extent) 

    gdf_extent_planar['lon'] = gdf_extent_planar['geometry'].x
    gdf_extent_planar['lat'] = gdf_extent_planar['geometry'].y

    print("\ngdf_extent_planar:")
    print(   gdf_extent_planar  )


##### ##### ##### ##### ##### ##### ##### ##### ##### #####
