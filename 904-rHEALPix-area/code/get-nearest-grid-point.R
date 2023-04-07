
get.nearest.grid.point <- function(
    SF.point         = NULL,
    SR.target        = NULL,
    mode             = 'vertex', # 'centroid'
    half.side.length = 1e3,
    save.shape.files = FALSE
    ) {

    thisFunctionName <- "generate.extents.aoi";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.point.target.projection <- sf::st_transform(
        x   = SF.point,
        crs = sf::st_crs(terra::crs(SR.target, proj = TRUE))
        );
    cat("\nSF.point.target.projection\n");
    print( SF.point.target.projection   );

    temp.coords <- sf::st_coordinates(SF.point.target.projection);
    crop.extent <- terra::ext(terra::rast(
        crs  = terra::crs(SR.target, proj = TRUE),
        xmin = temp.coords[,'X'] - half.side.length,
        xmax = temp.coords[,'X'] + half.side.length,
        ymin = temp.coords[,'Y'] - half.side.length,
        ymax = temp.coords[,'Y'] + half.side.length
        ));

    SR.cropped <- terra::crop(
        x = SR.target,
        y = crop.extent
        );

    DF.coords <- terra::crds(SR.cropped);
    cat("\nhead(DF.coords)\n");
    print( head(DF.coords)   );

    x.coords  <- sort(unique(DF.coords[,'x']));
    y.coords  <- sort(unique(DF.coords[,'y']));

    if ( mode == 'vertex' ) {
        x.coords <- x.coords[seq(1,length(x.coords)-1)] + diff(x.coords) / 2; 
        y.coords <- y.coords[seq(1,length(y.coords)-1)] + diff(y.coords) / 2;
        }

    abs.diff.x <- abs(x.coords - temp.coords[,'X']);
    abs.diff.y <- abs(y.coords - temp.coords[,'Y']);

    temp.X <- x.coords[ which(abs.diff.x == min(abs.diff.x)) ];
    temp.Y <- y.coords[ which(abs.diff.y == min(abs.diff.y)) ];

    SFC.output <- sf::st_sfc(
        sf::st_point(x = c(temp.X,temp.Y)),
        crs = sf::st_crs(terra::crs(SR.target, proj = TRUE))
        );
    cat("\nSFC.output\n");
    print( SFC.output   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( save.shape.files ) {

        SF.point.epsg.4326 <- sf::st_transform(
            x   = SF.point,
            crs = sf::st_crs(4326)
            );

        sf::st_write(
            obj = SF.point.epsg.4326,
            dsn = "point-given.shp"
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.output.epsg.4326 <- sf::st_transform(
            x   = SFC.output,
            crs = sf::st_crs(4326)
            );

        sf::st_write(
            obj = SF.output.epsg.4326,
            dsn = paste0("point-nearest-",mode,".shp")
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.coords <- sf::st_as_sf(
            x      = as.data.frame(DF.coords),
            crs    = sf::st_crs(terra::crs(SR.cropped, proj = TRUE)),
            coords = c('x','y')
            );

        SF.coords <- sf::st_transform(
            x   = SF.coords,
            crs = sf::st_crs(4326)
            );

        sf::st_write(
            obj = SF.coords,
            dsn = "grid-centroids.shp"
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SFC.output );

    }

##################################################
