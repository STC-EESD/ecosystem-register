#!/bin/bash

# https://open.canada.ca/data/en/dataset/ba2645d5-4458-414d-b196-6303ac06c1c9
# https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/

SHP_FILES=( \
    # 2021
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/supportdocument_documentdesupport/aci_crop_classifications_iac_classifications_des_cultures.csv" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_ab_v2.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_bc_v2.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_mb_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_nb_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_nl_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_ns_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_on_v2.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_pe_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_qc_v1.zip" \
    "https://agriculture.canada.ca/atlas/data_donnees/annualCropInventory/data_donnees/tif/2021/aci_2021_sk_v2.zip" \
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
