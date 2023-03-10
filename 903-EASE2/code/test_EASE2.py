
import numpy, pandas
import ease_grid, easepy

from geopandas        import GeoDataFrame
from shapely.geometry import Point, Polygon, LinearRing, LineString

##### ##### ##### ##### #####
def test_easepy():

    thisFunctionName = "test_easepy"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    df_refinement = pandas.DataFrame(
        data = {
            'resolution': [0,1,2,3,4,5],
            'refinement_ratio': [25,25,25,100,100,None],
            'resolution_m': [
                25000.0,
                 5000.0,
                 1000.0,
                  100.0,
                   10.0,
                    1.0
                ]
            }
        )

    print("\ndf_refinement\n")
    print(   df_refinement   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # retain only the first 2 rows (indexed by 0, 1)
    df_refinement = df_refinement.iloc[0:1]

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for rowindex in df_refinement.index:

        resolution    = df_refinement.at[rowindex,'resolution'  ]
        resolution_m  = df_refinement.at[rowindex,'resolution_m']

        print('rowindex:' + str(rowindex) + ', resolution:' + str(resolution) +', resolution_m:' + str(resolution_m))

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        shp_output = 'grid-easepy-r'+str(resolution)+'.shp'

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        # myGrid = ease_grid.EASE2_grid(res = side_length)
        myGrid = easepy.EaseGrid(
            resolution_m = resolution_m,
            projection   = "NorthHemi"
            )

        print("\ntype(myGrid)\n")
        print(   type(myGrid)   )

        print("\nmyGrid\n")
        print(   myGrid   )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myLats, myLons = myGrid.geodetic_grid 

        print("\nmyLats:\n")
        print(   myLats    )

        print("\nmyLons:\n")
        print(   myLons    )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGDF = GeoDataFrame(columns=['geomID','geometry'])

        for i in range(0,myLats.shape[0]):
            for j in range(0,myLats.shape[1]):
                tempLat = myLats[i,j]
                tempLon = myLons[i,j];
                myData = {
                    'geomID':   'meridian_' + '{:04d}'.format(i),
                    'geometry': Point(tempLon,tempLat)
                    }
                myRow = GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
                myGDF = pandas.concat([myGDF, myRow])


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
def test_ease_grid():

    thisFunctionName = "test_ease_grid"
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
    # retain only the first 2 rows (indexed by 0, 1)
    df_refinement = df_refinement.iloc[0:2]

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
