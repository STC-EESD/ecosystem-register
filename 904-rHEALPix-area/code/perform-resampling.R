
perform.resampling <- function(
    directory.aoi       = NULL,
    output.directory    = "output-resampling",
    WKT.NAD_1983_Albers = NULL,
    colour.NA           = 'black'
    ) {

    thisFunctionName <- "perform.resampling";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- normalizePath(getwd());

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.files <- list.files(
        path    = file.path(original.directory,directory.aoi),
        pattern = "\\.tiff$"
        );

    cat("\ntiff.files\n");
    print( tiff.files   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.tiff in tiff.files ) {
        perform.resampling_single.aoi(
            tiff.aoi           = temp.tiff,
            original.directory = original.directory,
            directory.aoi      = directory.aoi,
            output.directory   = output.directory
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( row.index in seq(1,nrow(DF.aoi)) ) {
    # for ( row.index in c(5,6) ) {

    #     temp.aoi      <- DF.aoi[row.index,'aoi'      ];
    #     temp.utm.zone <- DF.aoi[row.index,'utmzone'  ];
    #     temp.lon      <- DF.aoi[row.index,'longitude'];
    #     temp.lat      <- DF.aoi[row.index,'latitude' ];

    #     cat("\n### aoi:",temp.aoi,", UTM Zone:",temp.utm.zone,"\n");

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     temp.directory <- file.path(output.directory,temp.aoi);
    #     if ( !dir.exists(paths = temp.directory) ) {
    #         dir.create(path = temp.directory, recursive = TRUE);
    #         }
    #     setwd(temp.directory);

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     DF.point <- DF.aoi[row.index,];
    #     SF.epsg.4326.point <- sf::st_as_sf(
    #         x      = DF.point,
    #         crs    = sf::st_crs(4326),
    #         coords = c("longitude","latitude")
    #         );

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     SR.utm.zone <- assess.resampling_get.SpatRaster.UTM(
    #         data.directory = data.directory,
    #         data.snapshot  = data.snapshot,
    #         utm.zone       = temp.utm.zone
    #         );
    #     cat("\nSR.utm.zone\n");
    #     print( SR.utm.zone   );

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     SF.nearest.grid.point <- get.nearest.grid.point(
    #         SF.poi     = SF.epsg.4326.point,
    #         SR.target  = SR.utm.zone,
    #         point.type = 'vertex'
    #         );

    #     cat("\nSF.nearest.grid.point\n");
    #     print( SF.nearest.grid.point   );

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     output.stem <- paste0(temp.aoi,"-original");
    #     output.tiff <- paste0(output.stem,".tiff");
    #     output.png  <- paste0(output.stem,".png" );

    #     SR.cropped <- get.sub.spatraster(
    #         SF.grid.centre = SF.nearest.grid.point,
    #         SR.origin      = SR.utm.zone,
    #         x.ncell        = x.ncell,
    #         y.ncell        = y.ncell,
    #         TIF.output     = output.tiff
    #         );

    #     png(
    #         filename = output.png,
    #         res      = 300,
    #         width    =  12,
    #         height   =  10,
    #         units    = "in"
    #         );
    #     terra::plot(
    #         x     = SR.cropped,
    #         colNA = colour.NA
    #         );
    #     dev.off();

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     output.stem <- paste0(temp.aoi,"-collapsed");
    #     output.tiff <- paste0(output.stem,".tiff");
    #     output.png  <- paste0(output.stem,".png" );

    #     SR.collapsed <- collapse.classes.AAFC.SDLU(
    #         SR.input   = SR.cropped,
    #         TIF.output = output.tiff
    #         );

    #     png(
    #         filename = output.png,
    #         res      = 300,
    #         width    =  12,
    #         height   =  10,
    #         units    = "in"
    #         );
    #     terra::plot(
    #         x     = SR.collapsed,
    #         colNA = colour.NA
    #         );
    #     dev.off();

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     for ( aggregation.factor in seq(1,3) ) {
    #         temp.stem <- paste0("aggregated-f",aggregation.factor);
    #         assess.resampling_aggregate.crosstab(
    #             aoi                = temp.aoi,
    #             SR.input           = SR.cropped,
    #             aggregation.factor = aggregation.factor,
    #             crosstab.precision = crosstab.precision,
    #             TIF.output         = paste0(temp.stem,'.tiff'),
    #             PNG.output         = paste0(temp.stem,'.png' ),
    #             CSV.crosstab       = paste0(temp.stem,'-crosstab.csv')
    #             );
    #         }

    #     ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    #     setwd(original.directory);

    #     }


    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
perform.resampling_single.aoi <- function(
    tiff.aoi           = NULL,
    original.directory = NULL,
    directory.aoi      = NULL,
    output.directory   = NULL,
    aggregation.factor = 2,
    colour.NA          = 'black'
    ) {

    temp.directory <- gsub(
        x       = tiff.aoi,
        pattern = "raster-buffered-[0-9]{2}-",
        replacement = ""
        );
    temp.directory <- gsub(
        x           = temp.directory,
        pattern     = "\\.tiff",
        replacement = ""
        );
    temp.directory <- file.path(original.directory,output.directory,temp.directory);
    cat("\noriginal.directory\n");
    print( original.directory   );
    cat("\ntemp.directory\n");
    print( temp.directory   );
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SR.original <- terra::rast(
        file.path(original.directory,directory.aoi,tiff.aoi)
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    aggregation.factors <- c(1,2,3);
    collapsed.first     <- c(TRUE,FALSE);
    for ( temp.factor in aggregation.factors ) {
        
        output.stem <- paste0("aggregated-f",temp.factor);
        TIF.output  <- paste0(output.stem,".tiff");
        PNG.output  <- paste0(output.stem,".png" );

        terra::aggregate(
            x        = SR.original,
            fact     = aggregation.factor,
            fun      = 'modal',
            filename = TIF.output
            );
        SR.aggregated <- terra::rast(TIF.output);

        png(
            filename = PNG.output,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = 'in'
            );
        terra::plot(
            x     = SR.aggregated,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    terra::project(
        x        = SR.original,
        y        = terra::crs(SR.original),
        filename = "projected-100.tiff",
        method   = 'mode',
        res      = 100
        );
    SR.projected <- terra::rast("projected-100.tiff");
    levels(SR.projected) <- levels(SR.original);

    png(
        filename = "projected-100.png",
        res      = 300,
        width    =  12,
        height   =  10,
        units    = 'in'
        );
    terra::plot(
        x     = SR.projected,
        colNA = colour.NA
        );
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }
