
perform.resampling <- function(
    directory.aoi       = NULL,
    output.directory    = "output-resampling",
    WKT.NAD_1983_Albers = NULL,
    DF.coltab.SDLU      = NULL,
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
        perform.resampling_resample.reproject(
            tiff.aoi            = temp.tiff,
            original.directory  = original.directory,
            directory.aoi       = directory.aoi,
            WKT.NAD_1983_Albers = WKT.NAD_1983_Albers,
            DF.coltab.SDLU      = DF.coltab.SDLU,
            output.directory    = output.directory
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
perform.resampling_resample.reproject <- function(
    tiff.aoi            = NULL,
    original.directory  = NULL,
    directory.aoi       = NULL,
    WKT.NAD_1983_Albers = NULL,
    DF.coltab.SDLU      = NULL,
    output.directory    = NULL,
    aggregation.factor  = 2,
    colour.NA           = 'black'
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

    cat("\nhas.colors(SR.original)\n");
    print( has.colors(SR.original)   );

    cat("\nterra::coltab(SR.original)\n");
    print( terra::coltab(SR.original)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cumulative.stem <- "original-collapsed";

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    TIF.original.collapsed <- paste0(cumulative.stem,".tiff");
    PNG.original.collapsed <- paste0(cumulative.stem,".png" );

    collapse.classes.AAFC.SDLU(
        SR.input       = SR.original,
        DF.coltab.SDLU = DF.coltab.SDLU,
        TIF.output     = TIF.original.collapsed
        );
    SR.original.collapsed <- terra::rast(TIF.original.collapsed);
    terra::coltab(SR.original.collapsed) <- DF.coltab.SDLU[,c('value','col')];

    cat("\nhas.colors(SR.original.collapsed)\n");
    print( has.colors(SR.original.collapsed)   );

    cat("\nterra::coltab(SR.original.collapsed)\n");
    print( terra::coltab(SR.original.collapsed)   );

    png(
        filename = PNG.original.collapsed,
        res      = 300,
        width    =  12,
        height   =  10,
        units    = 'in'
        );
    terra::plot(
        x     = SR.original.collapsed,
        colNA = colour.NA
        );
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # just to capture levels and colours
    TIF.temp <- paste0(stringi::stri_rand_strings(n = 1, length = 10),".tiff");
    terra::aggregate(
        x        = SR.original.collapsed,
        fact     = 2,
        fun      = 'modal',
        filename = TIF.temp
        );
    SR.temp <- terra::rast(TIF.temp);
    temp.levels <- levels(SR.temp);
    temp.coltab <- terra::coltab(SR.temp);
    file.remove(TIF.temp);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # congruent downsampling

    aggregation.factors <- c(2,3);
    for ( temp.factor in aggregation.factors ) {

        TIF.aggregated <- paste0(cumulative.stem,"-aggregated-f",temp.factor,".tiff");
        PNG.aggregated <- paste0(cumulative.stem,"-aggregated-f",temp.factor,".png" );

        terra::aggregate(
            x        = SR.original.collapsed,
            fact     = temp.factor,
            fun      = 'modal',
            filename = TIF.aggregated
            );
        SR.aggregated <- terra::rast(TIF.aggregated);

        png(
            filename = PNG.aggregated,
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
    # incongruent downsampling

    spatial.resolutions <- c(100);
    for ( temp.resolution in spatial.resolutions ) {
        
        TIF.reprojected <- paste0(cumulative.stem,"-downsampled-mode-",temp.resolution,".tiff");
        PNG.reprojected <- paste0(cumulative.stem,"-downsampled-mode-",temp.resolution,".png" );

        terra::project(
            x        = SR.original.collapsed,
            y        = terra::crs(SR.original.collapsed),
            filename = TIF.reprojected,
            method   = 'mode',
            res      = temp.resolution
            );
        SR.reprojected <- terra::rast(TIF.reprojected);
        levels(SR.reprojected) <- temp.levels;
        terra::coltab(SR.reprojected) <- temp.coltab;

        png(
            filename = PNG.reprojected,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = 'in'
            );
        terra::plot(
            x     = SR.reprojected,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # reproject to Albers by mode

    spatial.resolutions <- c(30,100);
    for ( temp.resolution in spatial.resolutions ) {
        
        TIF.reprojected <- paste0(cumulative.stem,"-reprojected-mode-",temp.resolution,".tiff");
        PNG.reprojected <- paste0(cumulative.stem,"-reprojected-mode-",temp.resolution,".png" );

        terra::project(
            x        = SR.original.collapsed,
            y        = terra::crs(WKT.NAD_1983_Albers),
            filename = TIF.reprojected,
            method   = 'mode',
            res      = temp.resolution
            );
        SR.reprojected <- terra::rast(TIF.reprojected);
        levels(SR.reprojected) <- temp.levels;
        terra::coltab(SR.reprojected) <- temp.coltab;

        png(
            filename = PNG.reprojected,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = 'in'
            );
        terra::plot(
            x     = SR.reprojected,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # reproject to Albers by nearest neighbour

    spatial.resolutions <- c(30);
    for ( temp.resolution in spatial.resolutions ) {
        
        TIF.reprojected <- paste0(cumulative.stem,"-reprojected-near-",temp.resolution,".tiff");
        PNG.reprojected <- paste0(cumulative.stem,"-reprojected-near-",temp.resolution,".png" );

        terra::project(
            x        = SR.original.collapsed,
            y        = terra::crs(WKT.NAD_1983_Albers),
            filename = TIF.reprojected,
            method   = 'near',
            res      = temp.resolution
            );
        SR.reprojected <- terra::rast(TIF.reprojected);
        levels(SR.reprojected) <- temp.levels;
        terra::coltab(SR.reprojected) <- temp.coltab;

        png(
            filename = PNG.reprojected,
            res      = 300,
            width    =  12,
            height   =  10,
            units    = 'in'
            );
        terra::plot(
            x     = SR.reprojected,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    rm(list = c(
        "SR.original",
        "SR.original.collapsed",
        "SR.aggregated",
        "SR.projected"
        ));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }
