
import numpy, pandas
import ease_grid

from geopandas        import GeoDataFrame
from shapely.geometry import Point, Polygon, LinearRing, LineString

def test_EASE2():

    thisFunctionName = "test_EASE2"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    df_refinement = pandas.DataFrame(
        data = {
            'resolution': [0,1,2,3,4,5,6],
            'refinement_ratio': [16,9,9,100,100,100,None],
            'side_meters': [
                36032.220840,
                 9008.055210,
                 3002.685070,
                 1000.895020,
                  100.089500,
                   10.008950,
                    1.000895
                ]
            }
        )

    print("\ndf_refinement\n")
    print(   df_refinement   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # retain only the first 3 rows (indexed by 0, 1, 2)
    df_refinement = df_refinement.iloc[0:3]

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for rowindex in df_refinement.index:

        resolution  = df_refinement.at[rowindex,'resolution' ]
        side_length = df_refinement.at[rowindex,'side_meters']

        print('rowindex:' + str(rowindex) + ', resolution:' + str(resolution) +', side_length:' + str(side_length))

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        shp_output = 'grid-EASE2-r'+str(resolution)+'.shp'

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGrid = ease_grid.EASE2_grid(res = side_length)

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
        # myLons = numpy.append(myGrid.londim,myGrid.londim[0]) 
        # myLats = numpy.append(myGrid.latdim,myGrid.latdim[0]) 

        myLons = myGrid.londim
        myLats = myGrid.latdim

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGDF = GeoDataFrame(columns=['geomID','geometry'])

        i = 0
        for tempLongitude in myLons:
            myData = {
                'geomID':   'meridian_' + '{:04d}'.format(i),
                'geometry': LineString([Point(tempLongitude,y) for y in myLats])
                }
            myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
            myGDF = pandas.concat([myGDF, myRow])
            i = i + 1

        j = i
        for tempLatitude in myLats:
            myData = {
                'geomID':   'parallel_' + '{:04d}'.format(j),
                'geometry': LineString([Point(x,tempLatitude) for x in myLons])
                }
            myRow = GeoDataFrame(index = [j], data = myData, crs = "EPSG:4326")
            myGDF = pandas.concat([myGDF, myRow])
            j = j + 1

        print("myGDF:")
        print( myGDF  )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGDF.to_file(
            filename = shp_output,
            driver   = 'ESRI Shapefile'
            )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
