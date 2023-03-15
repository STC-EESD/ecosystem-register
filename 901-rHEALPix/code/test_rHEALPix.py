
import pandas

from rhealpixdggs.ellipsoids import *  
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs
from geopandas               import GeoDataFrame
from shapely.geometry        import Polygon, LinearRing, LineString

##### ##### ##### ##### #####
def generate_grid(
    grid_resolution = 2
    ):

    thisFunctionName = "generate_grid"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("WGS84_A:" + str(WGS84_A))
    print("WGS84_F:" + str(WGS84_F))
    print("WGS84_E:" + str(WGS84_E))

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

    myGrid = rHEALPixCanada.grid(resolution = grid_resolution)

    i = 0
    myGDF = GeoDataFrame(columns = ['cellID','geometry'], crs = "EPSG:4326")
    for myCell in myGrid:
        myData = {
            'cellID':   str(myCell),
            'geometry': LineString(myCell.boundary(plane = False))
            # 'geometry': Polygon(myCell.boundary(plane = False))
            # 'geometry': LinearRing(myCell.boundary(plane = False))
            }
        myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
        myGDF = pandas.concat([myGDF, myRow])
        i = i + 1
    print("myGDF:")
    print( myGDF  )

    shp_output = 'grid-rHEALPix-r' + '{:03d}'.format(grid_resolution) + '.shp'
    myGDF.to_file(
        filename = shp_output,
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
