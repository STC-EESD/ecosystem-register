
import pandas
import ease_grid

from geopandas        import GeoDataFrame
from shapely.geometry import Polygon, LinearRing, LineString

def test_EASE2():

    thisFunctionName = "test_EASE2"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    myGrid = ease_grid.EASE2_grid(res = 100 * 1000)

    print("\ntype(myGrid)\n")
    print(   type(myGrid)   )

    print("\nmyGrid\n")
    print(   myGrid   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("\nmyGrid.shape\n")
    print(   myGrid.shape   )

    print("\nmyGrid.londim\n")
    print(   myGrid.londim   )

    print("\nmyGrid.latdim\n")
    print(   myGrid.latdim   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
