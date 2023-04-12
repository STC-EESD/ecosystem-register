
assess.resampling <- function(
    DF.aoi               = NULL,
    DF.coltab            = NULL,
    data.directory       = NULL,
    data.snapshot        = NULL,
    x.ncell              = 1000,
    y.ncell              = 1000,
    crosstab.precision   =    4,
    proj4string.rHEALPix = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50",
    output.directory     = "output-resampling"
    ) {

    thisFunctionName <- "assess.resampling";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- getwd();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( row.index in seq(1,nrow(DF.aoi)) ) {
    for ( row.index in c(5,6) ) {

        temp.aoi      <- DF.aoi[row.index,'aoi'      ];
        temp.utm.zone <- DF.aoi[row.index,'utmzone'  ];
        temp.lon      <- DF.aoi[row.index,'longitude'];
        temp.lat      <- DF.aoi[row.index,'latitude' ];

        cat("\n### aoi:",temp.aoi,", UTM Zone:",temp.utm.zone,"\n");

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        temp.directory <- file.path(output.directory,temp.aoi);
        if ( !dir.exists(paths = temp.directory) ) {
            dir.create(path = temp.directory, recursive = TRUE);
            }
        setwd(temp.directory);

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.point <- DF.aoi[row.index,];
        SF.epsg.4326.point <- sf::st_as_sf(
            x      = DF.point,
            crs    = sf::st_crs(4326),
            coords = c("longitude","latitude")
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SR.utm.zone <- assess.resampling_get.SpatRaster.UTM(
            data.directory = data.directory,
            data.snapshot  = data.snapshot,
            utm.zone       = temp.utm.zone
            );
        cat("\nSR.utm.zone\n");
        print( SR.utm.zone   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.nearest.grid.point <- get.nearest.grid.point(
            SF.poi     = SF.epsg.4326.point,
            SR.target  = SR.utm.zone,
            point.type = 'vertex'
            );

        cat("\nSF.nearest.grid.point\n");
        print( SF.nearest.grid.point   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        output.stem <- paste0("original-",temp.utm.zone,"-",temp.aoi);
        output.tiff <- paste0(output.stem,".tiff");
        output.png  <- paste0(output.stem,".png" );

        SR.cropped <- get.sub.spatraster(
            SF.grid.centre = SF.nearest.grid.point,
            SR.origin      = SR.utm.zone,
            x.ncell        = x.ncell,
            y.ncell        = y.ncell,
            TIF.output     = output.tiff
            );

        png(
            filename = output.png,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = "in"
            );
        terra::plot(
            x     = SR.cropped,
            colNA = colour.NA
            );
        dev.off();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        for ( aggregation.factor in seq(1,3) ) {
            temp.stem <- paste0("aggregated-f",aggregation.factor);
            assess.resampling_aggregate.crosstab(
                aoi                = temp.aoi,
                SR.input           = SR.cropped,
                aggregation.factor = aggregation.factor,
                crosstab.precision = crosstab.precision,
                TIF.output         = paste0(temp.stem,'.tiff'),
                PNG.output         = paste0(temp.stem,'.png' ),
                CSV.crosstab       = paste0(temp.stem,'-crosstab.csv')
                );
            }

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        setwd(original.directory);

        }


    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
assess.resampling_aggregate.crosstab <- function(
    aoi                = NULL,
    SR.input           = NULL,
    aggregation.factor = NULL,
    crosstab.precision = NULL,
    TIF.output         = NULL,
    PNG.output         = NULL,
    CSV.crosstab       = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( aggregation.factor > 1 ) {
        terra::aggregate(
            x        = SR.input,
            fact     = aggregation.factor,
            fun      = 'modal',
            filename = TIF.output
            );
        SR.aggregated <- terra::rast(TIF.output);
        cat('\nSR.aggregated\n');
        print( SR.aggregated   );
    } else {
        SR.aggregated <- SR.input;
        }

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

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    TIF.cellSize <- paste0("tmp-cellSize-",aoi,".tiff");
    terra::cellSize(
        x         = SR.aggregated,
        filename  = TIF.cellSize
        );
    SR.cellsizes <- terra::rast(TIF.cellSize);

    DF.crosstab  <- terra::crosstab(
        x      = c(SR.cellsizes,SR.aggregated),
        digits = crosstab.precision
        );

    cat("\nstr(DF.crosstab)\n");
    print( str(DF.crosstab)   );
    cat("\nutils::head(x = DF.crosstab, n = 20L)\n");
    print( utils::head(x = DF.crosstab, n = 20L)   );

    write.csv(
        file = CSV.crosstab, 
        x    =  DF.crosstab
        );

    base::file.remove(TIF.cellSize);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }

assess.resampling_get.SpatRaster.UTM <- function(
    data.directory = NULL,
    data.snapshot  = NULL,
    utm.zone       = NULL
    ) {

    temp.dir  <- paste0("LU20.+_u",utm.zone,"$");
    temp.dir <- list.files(
        path    = file.path(data.directory,data.snapshot),
        pattern = temp.dir
        );
    cat("\nfile.path(data.directory,data.snapshot,temp.dir)\n");
    print( file.path(data.directory,data.snapshot,temp.dir)   );

    temp.tiff <- list.files(
        path    = file.path(data.directory,data.snapshot,temp.dir),
        pattern = "\\.tif$"
        );
    cat("\ntemp.tiff\n");
    print( temp.tiff   );

    TIF.utm.zone <- file.path(
        data.directory,
        data.snapshot,
        temp.dir,
        temp.tiff
        );
    cat("\nTIF.utm.zone\n");
    print( TIF.utm.zone   );

    SR.utm.zone <- terra::rast(x = TIF.utm.zone); 
    cat("\nSR.utm.zone\n");
    print( SR.utm.zone   );

    return( SR.utm.zone );

    }
