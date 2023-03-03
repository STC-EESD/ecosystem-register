
import pandas

from rhealpixdggs.ellipsoids import *  
from rhealpixdggs.dggs       import *
from rhealpixdggs            import dggs
from geopandas               import GeoDataFrame
from shapely.geometry        import Polygon, LinearRing, LineString

def test_rHEALPix():

    thisFunctionName = "test_rHEALPix"
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

    myGrid0 = rHEALPixCanada.grid(resolution = 0)
    print("myGrid0:")
    print([str(x) for x in myGrid0])

    # myGrid = rHEALPixCanada.grid(resolution = 0)
    # myGrid = rHEALPixCanada.grid(resolution = 1)
    myGrid = rHEALPixCanada.grid(resolution = 2)
    # myGrid = rHEALPixCanada.grid(resolution = 3)
    # myGrid = rHEALPixCanada.grid(resolution = 4)

    i = 0
    myGDF = GeoDataFrame(columns=['cellID','geometry'])
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

    myGDF.to_file(
        filename = 'myGrid.shp',
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
