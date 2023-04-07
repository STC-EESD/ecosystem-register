
get.nearest.grid.point <- function(
    SF.point    = NULL,
    SR.utm.zone = NULL,
    mode        = c('vertex','centroid')
    ) {

    thisFunctionName <- "generate.extents.aoi";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.point.utm <- sf::st_transform(
        x   = SF.point,
        crs = sf::st_crs(terra::crs(SR.utm.zone, proj = TRUE))
        );

    temp.coords <- sf::st_coordinates(SF.point.utm);
    crop.extent <- terra::ext(terra::rast(
        crs  = terra::crs(SR.utm.zone, proj = TRUE),
        xmin = temp.coords[,'X'] - 1e3,
        xmax = temp.coords[,'X'] + 1e3,
        ymin = temp.coords[,'Y'] - 1e3,
        ymax = temp.coords[,'Y'] + 1e3
        ));

    SR.cropped <- terra::crop(
        x = SR.utm.zone,
        y = crop.extent
        );

    DF.coords <- terra::crds(SR.cropped);
    x.coords  <- unique(DF.coords[,'x']);
    y.coords  <- unique(DF.coords[,'y']);

    abs.diff.x <- abs(x.coords - temp.coords[,'X']);
    abs.diff.y <- abs(y.coords - temp.coords[,'Y']);

    temp.X <- x.coords[ which(abs.diff.x == min(abs.diff.x)) ];
    temp.Y <- y.coords[ which(abs.diff.y == min(abs.diff.y)) ];

    # crop.extent <- terra::ext(terra::rast(
    #     crs  = terra::crs(SR.utm.zone, proj = TRUE),
    #     xmin = 445629.6 - 1e3,
    #     xmax = 445629.6 + 1e3,
    #     ymin = 5030368 - 1e3,
    #     ymax = 5030368 + 1e3
    #     ));

    # SR.cropped <- terra::crop(
    #     x = SR.utm.zone,
    #     y = crop.extent
    #     );

    # DF.coords <- terra::crds(SR.cropped);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    # return( NULL );
    return( c(temp.X,temp.Y) );

    }

##################################################
