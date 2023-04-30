
test_SpatRaster.to.polygons <- function(
    DF.aoi            = NULL,
    DF.coltab.SDLU    = NULL,
    data.directory    = NULL,
    data.snapshot     = NULL,
    point.type        = 'vertex', # 'centroid'
    x.ncell           = 6,
    y.ncell           = 6,
    colour.NA         = 'black',
    save.shape.files  = FALSE,
    shape.file.prefix = NULL,
    output.directory  = 'test-SpatRaster-to-polygons'
    ) {

    thisFunctionName <- 'test_SpatRaster.to.polygons';
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
    TIF.cropped <- 'SR-ottawa-cropped-precollapse.tiff';
    PNG.cropped <- 'SR-ottawa-cropped-precollapse.png';

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

    png(
        filename = PNG.cropped,
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

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    TIF.temp    <- paste0(paste(sample(x = c(LETTERS,letters), size = 10), collapse = ""),'.tiff');
    TIF.cropped <- 'SR-ottawa-cropped.tiff';
    PNG.cropped <- 'SR-ottawa-cropped.png';

    collapse.classes.AAFC.SDLU(
        SR.input       = SR.cropped,
        DF.coltab.SDLU = DF.coltab.SDLU,
        TIF.output     = TIF.temp
        );
    SR.cropped <- terra::rast(TIF.temp);

    levels(SR.cropped)        <- DF.coltab.SDLU[,c('value','category')];
    terra::coltab(SR.cropped) <- DF.coltab.SDLU[,c('value','col'     )];

    cat('\nSR.cropped\n');
    print( SR.cropped   );

    png(
        filename = PNG.cropped,
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

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- SpatRaster.to.polygons(
        input.SpatRaster = SR.cropped,
        factor.colnames  = 'LU2010'
        );

    cat("\nstr(list.output[['SF.multipolygons']])\n");
    print( str(list.output[['SF.multipolygons']])   );

    cat("\nstr(list.output[['SF.polygons']])\n");
    print( str(list.output[['SF.polygons']])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    sfarrow::st_write_parquet(
        dsn = "SF-multipolygons.parquet",
        obj = list.output[['SF.multipolygons']]
        );

    sfarrow::st_write_parquet(
        dsn = "SF-polygons.parquet",
        obj = list.output[['SF.polygons']]
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    terra::writeRaster(
        x         = SR.cropped,
        filename  = TIF.cropped,
        overwrite = FALSE
        );

    files.to.remove <- list.files(pattern = TIF.temp);
    file.remove(files.to.remove);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.polygons <- list.output[['SF.polygons']];

    DF.all.area.classes <- stats::aggregate(
        x    = as.formula("area_m2 ~ category"), # area_m2 ~ category,
        data = sf::st_drop_geometry(SF.polygons[,c('category','area_m2')]),
        FUN  = function(x) {return(c(
                n.polygons = length(x),
                meean      = mean(x),
                quantile(x = x, prob = c(0.00,0.25,0.50,0.75,0.95,1.00))
            ))}
        );
    DF.all.area.classes[,'n.pixels.class'] <- 'all.n.pixels.classes';

    SF.polygons[,'n.pixels.class'] <- 'n.pixels < 4';
    SF.polygons[unlist(sf::st_drop_geometry(SF.polygons[,'n.pixels'])) >= 4,'n.pixels.class'] <- '4 <= n.pixels < 9';
    SF.polygons[unlist(sf::st_drop_geometry(SF.polygons[,'n.pixels'])) >= 9,'n.pixels.class'] <- '9 <= n.pixels';

    DF.by.area.class <- stats::aggregate(
        x    = as.formula("area_m2 ~ category + n.pixels.class"), # area_m2 ~ category + n.pixels.class,
        data = sf::st_drop_geometry(SF.polygons[,c('category','n.pixels.class','area_m2')]),
        FUN  = function(x) {return(c(
                n.polygons = length(x),
                meean      = mean(x),
                quantile(x = x, prob = c(0.00,0.25,0.50,0.75,0.95,1.00))
            ))}
        );

    DF.polygon.statistics <- rbind(DF.all.area.classes,DF.by.area.class);

    write.csv(
        file      = 'DF-polygon-statistics.csv',
        x         = DF.polygon.statistics,
        row.names = FALSE
        );

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
