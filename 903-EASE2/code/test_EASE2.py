
import numpy, pandas, geopandas
import ease_grid, easepy

from shapely.geometry import Point, Polygon, LinearRing, LineString

##### ##### ##### ##### #####
def test_easepy():

    thisFunctionName = "test_easepy"
    print( "\n########## " + thisFunctionName + "() starts ..." )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    df_refinement = pandas.DataFrame(
        data = {
            'resolution': [0,1,2,3,4,5,6],
            'refinement_ratio': [25,25,25,100,100,100,None],
            'resolution_m': [
                250000.0,
                 50000.0,
                 10000.0,
                  1000.0,
                   100.0,
                    10.0,
                     1.0,
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
        centroidLats, centroidLons = myGrid.geodetic_grid

        print("\ncentroidLats:\n")
        print(   centroidLats    )

        print("\ncentroidLons:\n")
        print(   centroidLons    )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        gdfCentroids = geopandas.GeoDataFrame(
            columns = ['geomID','geometry'],
            crs     = "EPSG:4326"
            )

        temp_DF = pandas.DataFrame({
            'lon': centroidLons[0,:],
            'lat': centroidLats[0,:]
            }) 
        tempGDF = geopandas.GeoDataFrame(
            data     = temp_DF,
            crs      = "EPSG:4326",
            geometry = geopandas.points_from_xy(x = temp_DF.lon, y = temp_DF.lat)
            )
        gdfCentroids = pandas.concat([gdfCentroids,tempGDF])

        temp_DF = pandas.DataFrame({
            'lon': centroidLons[:,0],
            'lat': centroidLats[:,0]
            })
        tempGDF = geopandas.GeoDataFrame(
            data     = temp_DF,
            crs      = "EPSG:4326",
            geometry = geopandas.points_from_xy(x = temp_DF.lon, y = temp_DF.lat)
            )
        gdfCentroids = pandas.concat([gdfCentroids,tempGDF])

        gdfCentroids = gdfCentroids.to_crs(
            epsg    = 6931,
            inplace = False
            )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myLons = gdfCentroids.geometry.x.round(decimals = 0).unique()
        myLats = gdfCentroids.geometry.y.round(decimals = 0).unique()

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGDF = geopandas.GeoDataFrame(
            columns = ['geomID','geometry'],
            crs     = "EPSG:6931"
            )

        i = 0
        for tempLongitude in myLons:
            myData = {
                'geomID':   'meridian_' + '{:04d}'.format(i),
                'geometry': LineString([Point(tempLongitude,y) for y in myLats])
                }
            myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = "EPSG:6931")
            myGDF = pandas.concat([myGDF, myRow])
            i = i + 1

        j = 0
        k = i
        for tempLatitude in myLats:
            myData = {
                'geomID':   'parallel_' + '{:04d}'.format(j),
                'geometry': LineString([Point(x,tempLatitude) for x in myLons])
                }
            myRow = geopandas.GeoDataFrame(index = [k], data = myData, crs = "EPSG:6931")
            myGDF = pandas.concat([myGDF, myRow])
            j = j + 1
            k = k + 1


        myGDF = myGDF.set_crs(
            crs            = 6931,
            allow_override = True
            )

        myGDF = myGDF.to_crs(
            epsg    = 4326,
            inplace = False
            )

        print("myGDF:")
        print( myGDF  )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        myGDF.to_file(
            filename = shp_output,
            driver   = 'ESRI Shapefile'
            )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

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
        # centroidLons = numpy.append(myGrid.londim,myGrid.londim[0]) 
        # centroidLats = numpy.append(myGrid.latdim,myGrid.latdim[0]) 

        centroidLons = myGrid.londim
        centroidLats = myGrid.latdim

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        gdfCentroids = geopandas.GeoDataFrame(columns=['geomID','geometry'])

        i = 0
        for tempLongitude in centroidLons:
            myData = {
                'geomID':   'meridian_' + '{:04d}'.format(i),
                'geometry': LineString([Point(tempLongitude,y) for y in centroidLats])
                }
            myRow = geopandas.GeoDataFrame(index = [i], data = myData, crs = "EPSG:4326")
            gdfCentroids = pandas.concat([gdfCentroids, myRow])
            i = i + 1

        j = i
        for tempLatitude in centroidLats:
            myData = {
                'geomID':   'parallel_' + '{:04d}'.format(j),
                'geometry': LineString([Point(x,tempLatitude) for x in centroidLons])
                }
            myRow = geopandas.GeoDataFrame(index = [j], data = myData, crs = "EPSG:4326")
            gdfCentroids = pandas.concat([gdfCentroids, myRow])
            j = j + 1

        print("gdfCentroids:")
        print( gdfCentroids  )

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        gdfCentroids.to_file(
            filename = shp_output,
            driver   = 'ESRI Shapefile'
            )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print( "\n########## " + thisFunctionName + "() exits ..." )
    return( None )

##### ##### ##### ##### #####
