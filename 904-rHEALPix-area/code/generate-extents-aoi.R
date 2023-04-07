
generate.extents.aoi <- function(
    DF.aoi               = NULL,
    DF.coltab            = NULL,
    data.directory       = NULL,
    data.snapshot        = NULL,
    xncell               = 1000,
    yncell               = 1000,
    crosstab.precision   =    4,
    proj4string.rHEALPix = "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50",
    output.directory     = "output-aoi"
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
            SF.point   = SF.epsg.4326.point,
            SR.target  = SR.utm.zone,
            point.type = 'vertex'
            );

        cat("\nSF.nearest.grid.point\n");
        print( SF.nearest.grid.point   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.nearest.grid.point <- sf::st_coordinates(x = SF.nearest.grid.point);

        cat("\nDF.nearest.grid.point\n");
        print( DF.nearest.grid.point   );

        temp.coords <- sf::st_coordinates(SF.nearest.grid.point);
        crop.extent <- terra::ext(terra::rast(
            crs  = terra::crs(SR.utm.zone, proj = TRUE),
            xmin = DF.nearest.grid.point[1,'X'] - xncell * xres.utm.zone,
            xmax = DF.nearest.grid.point[1,'X'] + xncell * xres.utm.zone,
            ymin = DF.nearest.grid.point[1,'Y'] - yncell * yres.utm.zone,
            ymax = DF.nearest.grid.point[1,'Y'] + yncell * yres.utm.zone
            ));

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        output.stem <- paste0("raster-buffered-",temp.utm.zone,"-",temp.aoi);
        output.tiff <- file.path(output.directory,paste0(output.stem,".tiff"));
        output.png  <- file.path(output.directory,paste0(output.stem,".png" ));

        terra::crop(
            x        = SR.utm.zone,
            y        = crop.extent,
            filename = output.png
            );
        terra::crop(
            x        = SR.utm.zone,
            y        = crop.extent,
            filename = output.tiff
            );
        SR.cropped <- terra::rast(output.tiff);

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        generate.extents.aoi_extent(
            input.raster     = SR.cropped, # aoi.raster,
            utm.zone         = temp.utm.zone,
            aoi              = temp.aoi,
            proj4string      = terra::crs(x = SR.cropped, proj = TRUE),
            map.projection   = "original",
            output.directory = output.directory
            );

        generate.extents.aoi_extent(
            input.raster     = SR.cropped, # aoi.raster,
            utm.zone         = temp.utm.zone,
            aoi              = temp.aoi,
            proj4string      = proj4string.rHEALPix,
            map.projection   = "rHEALPix-planar",
            output.directory = output.directory
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        terra::cellSize(
            x         = SR.cropped,
            filename  = "tmp-cellSize.tiff"
            );
        SR.cellsizes <- terra::rast("tmp-cellSize.tiff");

        DF.crosstab  <- terra::crosstab(
            x      = c(SR.cellsizes,SR.cropped),
            digits = crosstab.precision
            );

        cat("\nstr(DF.crosstab)\n");
        print( str(DF.crosstab)   );
        cat("\nutils::head(x = DF.crosstab, n = 20L)\n");
        print( utils::head(x = DF.crosstab, n = 20L)   );

        output.csv <- file.path(
            output.directory,
            paste0("xtab-",temp.utm.zone,"-",temp.aoi,".csv")
            );
        write.csv(
            file = output.csv, 
            x    = DF.crosstab
            );

        base::file.remove("tmp-cellSize.tiff");

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
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
