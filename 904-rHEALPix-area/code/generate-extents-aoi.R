
generate.extents.aoi <- function(
    DF.aoi               = NULL,
    DF.coltab            = NULL,
    data.directory       = NULL,
    data.snapshot        = NULL,
    delta.lon            = 1.00,
    delta.lat            = 0.50,
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
        temp.province <- DF.aoi[row.index,'province' ];
        temp.lon      <- DF.aoi[row.index,'longitude'];
        temp.lat      <- DF.aoi[row.index,'latitude' ];

        cat("\n### aoi:",temp.aoi,", province:",temp.province,"\n");

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        aoi.raster <- terra::rast(
            crs   = "epsg:4326",
            xmin  = temp.lon - delta.lon,
            xmax  = temp.lon + delta.lon,
            ymin  = temp.lat - delta.lat,
            ymax  = temp.lat + delta.lat
            );

        generate.extents.aoi_extent(
            input.raster     = aoi.raster,
            province         = temp.province,
            aoi              = temp.aoi,
            proj4string      = terra::crs(x = aoi.raster, proj = TRUE),
            map.projection   = "lonlat",
            output.directory = output.directory
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
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
        aoi.raster <- terra::project(
            x = aoi.raster,
            y = terra::crs(province.raster)
            );
        aoi.extent <- terra::ext(aoi.raster);
        aoi.raster <- terra::crop(
            x = province.raster,
            y = aoi.extent
            ); 
        terra::coltab(aoi.raster) <- DF.coltab;
        cat("\naoi.raster\n");
        print( aoi.raster   );

        generate.extents.aoi_extent(
            input.raster     = aoi.raster,
            province         = temp.province,
            aoi              = temp.aoi,
            proj4string      = terra::crs(x = aoi.raster, proj = TRUE),
            map.projection   = "original",
            output.directory = output.directory
            );

        generate.extents.aoi_extent(
            input.raster     = aoi.raster,
            province         = temp.province,
            aoi              = temp.aoi,
            proj4string      = proj4string.rHEALPix,
            map.projection   = "rHEALPix-planar",
            output.directory = output.directory
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        output.stem <- paste0("raster-buffered-",temp.province,"-",temp.aoi);
        output.tiff <- file.path(output.directory,paste0(output.stem,".tiff"));
        output.png  <- file.path(output.directory,paste0(output.stem,".png" ));

        terra::writeRaster(
            x        = aoi.raster,
            filename = output.tiff
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
            paste0("xtab-",temp.province,"-",temp.aoi,".csv")
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
generate.extents.aoi_extent <- function(
    input.raster       = NULL,
    province           = NULL,
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

    output.stem <- paste0("extent-point-",map.projection,"-",province,"-",aoi);

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

    output.stem <- paste0("extent-point-",map.projection,"-",province,"-",aoi,"-lonlat");

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
    province             = NULL,
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

    output.stem <- paste0("extent-point-rHEALPix-planar-",province,"-",aoi);

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

    output.stem <- paste0("extent-point-EPSG-4326-",province,"-",aoi);

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
