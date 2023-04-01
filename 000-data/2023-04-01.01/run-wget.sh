#!/bin/bash

# https://open.canada.ca/data/en/dataset/fa84a70f-03ad-4946-b0f8-a3b481dd5248
# https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/

SHP_FILES=( \
    # 2020
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u07.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u08.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u09.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u10.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u11.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u12.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u13.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u14.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u15.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u16.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u17.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u18.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u19.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u20.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u21.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/landuse/data_donnees/tif/2020/LU2020_u22.zip" \
    )

### ~~~~~~~~~~ ###
dataRepository=~/minio/standard/shared/randd-eesd/001-data-repository/001-acquired/nfis-change
if [ `uname` != "Darwin" ]
then
    cp $0 ${dataRepository}
fi

### ~~~~~~~~~~ ###
for tempzip in "${SHP_FILES[@]}"
do

    echo;echo downloading: ${tempzip}
    wget ${tempzip}
    sleep 5

    tempstem=`basename ${tempzip} .zip`
    tempzip=${tempstem}.zip

    echo unzipping: ${tempzip}
    # unzip ${tempzip} -d ${tempstem}
    unzip ${tempzip}
    sleep 5

    # if [ `uname` != "Darwin" ]
    # then
    #     tempstem=`basename ${tempzip} .zip`
    #     tempzip=${tempstem}.zip

    #     echo unzipping: ${tempzip}
    #     unzip ${tempzip} -d ${tempstem}
    #     sleep 5

    #     # # Copy multiple local folders recursively to MinIO cloud storage.
    #     # echo copying ${tempstem} to ${dataRepository}
    #     # mc-original cp --recursive ${tempstem} ${dataRepository}
    #     # sleep 5

    #     # echo deleting ${tempstem}
    #     # rm -rf ${tempstem}
    #     # sleep 5
    # fi

done
echo

### ~~~~~~~~~~ ###
echo; echo done; echo

### ~~~~~~~~~~ ###
# if [ `uname` != "Darwin" ]
# then
#     if compgen -G "std*" > /dev/null; then
#         cp std* ${dataRepository}
#     fi
# fi
