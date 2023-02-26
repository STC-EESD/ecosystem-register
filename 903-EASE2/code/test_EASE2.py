
import pandas
import ease_grid

from geopandas        import GeoDataFrame
from shapely.geometry import Point, Polygon, LinearRing, LineString

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
    myGDF = GeoDataFrame(columns=['geomID','geometry'])

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    i = 0
    for tempLongitude in myGrid.londim:
        myData = {
            'geomID':   'meridian_' + '{:04d}'.format(i),
            'geometry': LineString([Point(tempLongitude,y) for y in myGrid.latdim])
            }
        myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
        myGDF = pandas.concat([myGDF, myRow])
        i = i + 1

    j = i
    for tempLatitude in myGrid.latdim:
        myData = {
            'geomID':   'parallel_' + '{:04d}'.format(j),
            'geometry': LineString([Point(x,tempLatitude) for x in myGrid.londim])
            }
        myRow = GeoDataFrame(index = [j], data = myData, crs = "EPSG:4326")
        myGDF = pandas.concat([myGDF, myRow])
        j = j + 1

    print("myGDF:")
    print( myGDF  )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    myGDF.to_file(
        filename = 'myGrid.shp',
        driver   = 'ESRI Shapefile'
        )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
