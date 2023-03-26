
generate.extents.aoi <- function(
    DF.aoi           = NULL,
    data.directory   = NULL,
    data.snapshot    = NULL,
    delta.lon        = 1.00,
    delta.lat        = 0.50,
    output.directory = "output-aoi"
    ) {

    thisFunctionName <- "generate.extents.aoi";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( row.index in seq(1,nrow(DF.aoi)) ) {
    for ( row.index in c(5,6) ) {

        temp.aoi      <- DF.aoi[row.index,'aoi'      ];
        temp.province <- DF.aoi[row.index,'province' ];
        temp.lon      <- DF.aoi[row.index,'longitude'];
        temp.lat      <- DF.aoi[row.index,'latitude' ];

        cat("\n### aoi:",temp.aoi,", province:",temp.province,"\n");

        TIF.aci.2021.province <- file.path(
            data.directory,
            data.snapshot,
            paste0("aci_2021_",temp.province,".tif")
            );
        cat("\nTIF.aci.2021.province\n");
        print( TIF.aci.2021.province   );

        province.raster <- terra::rast(x = TIF.aci.2021.province); 
        cat("\nprovince.raster\n");
        print( province.raster   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        aoi.raster <- terra::rast(
            crs   = "epsg:4326",
            xmin  = temp.lon - delta.lon,
            xmax  = temp.lon + delta.lon,
            ymin  = temp.lat - delta.lat,
            ymax  = temp.lat + delta.lat
            );
        aoi.raster <- terra::project(
            x = aoi.raster,
            y = terra::crs(province.raster)
            );
        aoi.extent <- terra::ext(aoi.raster);
        aoi.raster <- terra::crop(
            x = province.raster,
            y = aoi.extent
            ); 
        cat("\naoi.raster\n");
        print( aoi.raster   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        output.png <- file.path(
            output.directory,
            paste0("raster-aci-2021-",temp.province,"-",temp.aoi,".png")
            );

        png(
            filename = output.png,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = "in"
            );
        terra::plot(
            x     = aoi.raster,
            # col = NDVI.colour.palette,
            colNA = colour.NA
            );
        dev.off();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        aoi.cellsizes <- terra::cellSize(x = aoi.raster);
        DF.crosstab   <- terra::crosstab(c(aoi.raster,aoi.cellsizes));

        cat("\nstr(DF.crosstab)\n");
        print( str(DF.crosstab)   );
        cat("\nDF.crosstab\n");
        print( DF.crosstab   );

        output.csv <- file.path(
            output.directory,
            paste0("xtab-aci-2021-",temp.province,"-",temp.aoi,".csv")
            );
        write.csv(
            file = output.csv, 
            x    = DF.crosstab
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
