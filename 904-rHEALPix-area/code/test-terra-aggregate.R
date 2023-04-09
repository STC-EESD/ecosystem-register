
test_terra.aggregate <- function(
    DF.aoi            = NULL,
    data.directory    = NULL,
    data.snapshot     = NULL,
    point.type        = 'vertex', # 'centroid'
    x.ncell           = 6,
    y.ncell           = 6,
    save.shape.files  = FALSE,
    shape.file.prefix = NULL,
    output.directory  = 'test-terra-aggregate'
    ) {

    thisFunctionName <- 'test_terra.aggregate';
    cat('\n### ~~~~~~~~~~~~~~~~~~~~ ###');
    cat(paste0('\n',thisFunctionName,'() starts.\n\n'));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- base::getwd();

    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    base::setwd(output.directory);
    cat('\nbase::getwd()\n');
    print( base::getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.ottawa <- DF.aoi[DF.aoi[,'aoi'] == 'ottawa',];
    cat('\nDF.ottawa\n');
    print( DF.ottawa   );

    SF.epsg.4326.ottawa <- sf::st_as_sf(
        x      = DF.ottawa,
        crs    = sf::st_crs(4326),
        coords = c('longitude','latitude')
        );
    cat('\nSF.epsg.4326.ottawa\n');
    print( SF.epsg.4326.ottawa   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.dir  <- paste0('LU2010_u',DF.ottawa[,'utmzone']);
    temp.tiff <- list.files(
        path    = file.path(data.directory,data.snapshot,temp.dir),
        pattern = "\\.tif$"
        );

    TIF.utm.zone <- file.path(
        data.directory,
        data.snapshot,
        temp.dir,
        temp.tiff
        );
    cat('\nTIF.utm.zone\n');
    print( TIF.utm.zone   );

    SR.utm.zone <- terra::rast(x = TIF.utm.zone); 
    cat('\nSR.utm.zone\n');
    print( SR.utm.zone   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.grid.centre <- get.nearest.grid.point(
        SF.poi           = SF.epsg.4326.ottawa,
        SR.target        = SR.utm.zone,
        point.type       = point.type,
        half.side.length = 150,
        save.shape.files = FALSE
        );

    cat('\nSF.grid.centre\n');
    print( SF.grid.centre   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    TIF.cropped <- 'SR-ottawa-cropped.tiff';
    get.sub.spatraster(
        SF.grid.centre = SF.grid.centre,
        SR.origin      = SR.utm.zone,
        x.ncell        = x.ncell,
        y.ncell        = y.ncell,
        TIF.output     = TIF.cropped
        );
    SR.cropped <- terra::rast(TIF.cropped);
    cat('\nSR.cropped\n');
    print( SR.cropped   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( aggregation.factor in seq(1,3) ) {
        temp.stem <- paste0("SF-f",aggregation.factor);
        test_terra.aggregate_inner(
            SR.input           = SR.cropped,
            aggregation.factor = aggregation.factor,
            TIF.output         = paste0(temp.stem,'.tiff'),
            PNG.output         = paste0(temp.stem,'.png' ),
            SHP.prefix         = temp.stem
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    base::setwd(original.directory);
    cat('\nbase::getwd()\n');
    print( base::getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0('\n',thisFunctionName,'() quits.'));
    cat('\n### ~~~~~~~~~~~~~~~~~~~~ ###\n');
    return( NULL );

    }

##################################################
test_terra.aggregate_inner <- function(
    SR.input           = NULL,
    aggregation.factor = NULL,
    TIF.output         = NULL,
    PNG.output         = NULL,
    SHP.prefix         = NULL
    ) {

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

    list.grid.info <- extract.grid.from.SpatRaster(
        SR.input = SR.aggregated
        );

    get.nearest.grid.point_save.shape.files(
        list.grid.info    = list.grid.info,
        shape.file.prefix = SHP.prefix
        );

    return( NULL );

    }
