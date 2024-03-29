
generate.extents.aoi <- function(
    DF.aoi               = NULL,
    SF.provinces         = NULL,
    DF.coltab            = NULL,
    data.directory       = NULL,
    data.snapshot        = NULL,
    x.ncell              = 1000,
    y.ncell              = 1000,
    crosstab.precision   =    4,
    colour.NA            = 'black',
    proj4string.rHEALPix = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50",
    output.directory     = "output-aoi"
    ) {

    thisFunctionName <- "generate.extents.aoi";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(paths = output.directory) ) {
        cat("The directory",output.directory,"already exists; do nothing ...");
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
    } else {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.aoi.points   <- NULL;
    SF.aoi.polygons <- NULL;

    # for ( row.index in c(5,6) ) {
    for ( row.index in seq(1,nrow(DF.aoi)) ) {

        temp.aoi      <- DF.aoi[row.index,'aoi'      ];
        temp.utm.zone <- DF.aoi[row.index,'utmzone'  ];
        temp.lon      <- DF.aoi[row.index,'longitude'];
        temp.lat      <- DF.aoi[row.index,'latitude' ];

        cat("\n### aoi:",temp.aoi,", UTM Zone:",temp.utm.zone,"\n");

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.point <- DF.aoi[row.index,];
        SF.epsg.4326.point <- sf::st_as_sf(
            x      = DF.point,
            crs    = sf::st_crs(4326),
            coords = c("longitude","latitude")
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        temp.dir  <- paste0("LU20.+_u",temp.utm.zone,"$");
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

        xres.utm.zone <- terra::xres(x = SR.utm.zone);
        yres.utm.zone <- terra::yres(x = SR.utm.zone);

        cat("\nxres.utm.zone\n");
        print( xres.utm.zone   );

        cat("\nyres.utm.zone\n");
        print( yres.utm.zone   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.nearest.grid.point <- get.nearest.grid.point(
            SF.poi     = SF.epsg.4326.point,
            SR.target  = SR.utm.zone,
            point.type = 'vertex'
            );

        cat("\nSF.nearest.grid.point\n");
        print( SF.nearest.grid.point   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        output.stem <- paste0("raster-buffered-",temp.utm.zone,"-",temp.aoi);
        output.tiff <- file.path(output.directory,paste0(output.stem,".tiff"));
        output.png  <- file.path(output.directory,paste0(output.stem,".png" ));

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
        SR.extent <- terra::ext(SR.cropped);
        SV.extent <- terra::as.polygons(SR.extent);
        SF.extent <- sf::st_as_sf(SV.extent);
        sf::st_crs(SF.extent) <- terra::crs(x = SR.cropped, proj = TRUE);
        SF.extent <- sf::st_transform(
            x   = SF.extent,
            crs = sf::st_crs("epsg:4326")
            );
        SF.point <- sf::st_cast(x = SF.extent, to = "POINT");

        if ( is.null(SF.aoi.polygons) ) {
            SF.aoi.polygons <- SF.extent;
            SF.aoi.points   <- SF.point;
        } else {
            SF.aoi.polygons <- rbind(SF.aoi.polygons,SF.extent);
            SF.aoi.points   <- rbind(SF.aoi.points,  SF.point );
            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    sf::st_write(
        obj = SF.aoi.polygons,
        dsn = file.path(output.directory,"SF-aoi-polygons.shp")
        );

    sf::st_write(
        obj = SF.aoi.points,
        dsn = file.path(output.directory,"SF-aoi-points.shp")
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( nchar(system.file(package='tmap')) > 0 ) {
        generate.extents.aoi_generate.map(
            SF.provinces     = SF.provinces,
            SF.aoi.polygons  = SF.aoi.polygons,
            SF.aoi.points    = SF.aoi.points,
            output.directory = output.directory
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
generate.extents.aoi_generate.map <- function(
    SF.provinces     = NULL,
    SF.aoi.polygons  = NULL,
    SF.aoi.points    = NULL,
    output.directory = NULL
    ) {


    my.tmap <- tmap::tm_shape(SF.provinces) + tmap::tm_borders();
    my.tmap <- my.tmap + tmap::tm_shape(SF.aoi.polygons) + tmap::tm_sf(
        col   = "orange",
        alpha = 0.5
        );
    # my.tmap <- my.tmap + tmap::tm_shape(SF.aoi.points) + tmap::tm_dots( # tmap::tm_bubbles(
    #     size  = 5,
    #     col   = "orange",
    #     alpha = 0.5
    #     );
    my.tmap <- my.tmap + tmap::tm_layout(
        legend.position   = c("right","bottom"),
        legend.title.size = 1.0,
        legend.text.size  = 0.8
        );

    # cat("\nstr(my.tmap)\n");
    # print( str(my.tmap)   );

    PNG.output <- paste0("plot-aoi-map.png");
    tmap::tmap_save(
        tm       = my.tmap,
        filename = file.path(output.directory,PNG.output),
        width    = 16,
        # height =  8,
        units    = "in",
        dpi      = 300
        );

    return( NULL );

    }

generate.extents.aoi_extent <- function(
    input.raster       = NULL,
    utm.zone           = NULL,
    aoi                = NULL,
    proj4string.target = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50",
    map.projection     = "rHEALPix-planar",
    output.directory   = "output-aoi"
    ) {

    my.extent.target <- terra::ext(
        x = terra::project(
            x      = input.raster,
            y      = proj4string.target,
            method = 'bilinear'
            )
        );

    cat("\nmy.extent.target\n");
    print( my.extent.target   );

    my.xmin <- terra::xmin(my.extent.target);
    my.xmax <- terra::xmax(my.extent.target);

    my.ymin <- terra::ymin(my.extent.target);
    my.ymax <- terra::ymax(my.extent.target);

    DF.extent <- base::as.data.frame(base::matrix(
        data = c(
            my.xmin, my.ymin,
            my.xmax, my.ymin,
            my.xmax, my.ymax,
            my.xmin, my.ymax
            ),
        dimnames = list(
            c('xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax'),
            c('x','y')
            ),
        byrow    = TRUE,
        nrow     = 4,
        ncol     = 2
        ));
    DF.extent[,'label'] <- rownames(DF.extent);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.extent <- sf::st_as_sf(
        x      = DF.extent,
        coords = c("x","y"),
        crs    = proj4string.target 
        );

    cat("\nSF.extent (target)\n");
    print( SF.extent );

    output.stem <- paste0("extent-point-",map.projection,"-",utm.zone,"-",aoi);

    sf::st_write(
        obj = SF.extent,
        dsn = file.path(output.directory,paste0(output.stem,".shp"))
        );

    sf::st_write(
        obj = SF.extent,
        dsn = file.path(output.directory,paste0(output.stem,".geojson"))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.extent <- sf::st_transform(
        x   = SF.extent,
        crs = sf::st_crs(4326)
        );

    cat("\nSF.extent (EPSG.4326)\n");
    print( SF.extent );

    output.stem <- paste0("extent-point-",map.projection,"-",utm.zone,"-",aoi,"-lonlat");

    sf::st_write(
        obj = SF.extent,
        dsn = file.path(output.directory,paste0(output.stem,".shp"))
        );

    sf::st_write(
        obj = SF.extent,
        dsn = file.path(output.directory,paste0(output.stem,".geojson"))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }

generate.extents.aoi_rHEALPix.extent <- function(
    input.raster         = NULL,
    utm.zone             = NULL,
    aoi                  = NULL,
    proj4string.rHEALPix = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50",
    output.directory     = "output-aoi"
    ) {

    my.extent.rHEALPix <- terra::ext(
        x = terra::project(
            x      = input.raster,
            y      = proj4string.rHEALPix,
            method = 'bilinear'
            )
        );

    cat("\nmy.extent.rHEALPix\n");
    print( my.extent.rHEALPix   );

    my.xmin.rHEALPix <- terra::xmin(my.extent.rHEALPix);
    my.xmax.rHEALPix <- terra::xmax(my.extent.rHEALPix);

    my.ymin.rHEALPix <- terra::ymin(my.extent.rHEALPix);
    my.ymax.rHEALPix <- terra::ymax(my.extent.rHEALPix);

    DF.extent.rHEALPix <- base::as.data.frame(base::matrix(
        data = c(
            my.xmin.rHEALPix,my.ymin.rHEALPix,
            my.xmax.rHEALPix,my.ymin.rHEALPix,
            my.xmax.rHEALPix,my.ymax.rHEALPix,
            my.xmin.rHEALPix,my.ymax.rHEALPix
            ),
        dimnames = list(
            c('xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax'),
            c('x','y')
            ),
        byrow    = TRUE,
        nrow     = 4,
        ncol     = 2
        ));
    DF.extent.rHEALPix[,'label'] <- rownames(DF.extent.rHEALPix);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.extent.rHEALPix <- sf::st_as_sf(
        x      = DF.extent.rHEALPix,
        coords = c("x","y"),
        crs    = proj4string.rHEALPix 
        );

    cat("\nSF.extent.rHEALPix\n");
    print( SF.extent.rHEALPix   );

    output.stem <- paste0("extent-point-rHEALPix-planar-",utm.zone,"-",aoi);

    sf::st_write(
        obj = SF.extent.rHEALPix,
        dsn = file.path(output.directory,paste0(output.stem,".shp"))
        );

    sf::st_write(
        obj = SF.extent.rHEALPix,
        dsn = file.path(output.directory,paste0(output.stem,".geojson"))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.extent.EPSG.4326 <- sf::st_transform(
        x   = SF.extent.rHEALPix,
        crs = sf::st_crs(4326)
        );

    cat("\nSF.extent.EPSG.4326\n");
    print( SF.extent.EPSG.4326   );

    output.stem <- paste0("extent-point-EPSG-4326-",utm.zone,"-",aoi);

    sf::st_write(
        obj = SF.extent.EPSG.4326,
        dsn = file.path(output.directory,paste0(output.stem,".shp"))
        );

    sf::st_write(
        obj = SF.extent.EPSG.4326,
        dsn = file.path(output.directory,paste0(output.stem,".geojson"))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }
