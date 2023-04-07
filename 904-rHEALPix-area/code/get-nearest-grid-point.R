
get.nearest.grid.point <- function(
    SF.point         = NULL,
    SR.target        = NULL,
    mode             = c('vertex','centroid'),
    half.side.length = 1e3
    ) {

    thisFunctionName <- "generate.extents.aoi";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.point.target.projection <- sf::st_transform(
        x   = SF.point,
        crs = sf::st_crs(terra::crs(SR.target, proj = TRUE))
        );

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
    x.coords  <- unique(DF.coords[,'x']);
    y.coords  <- unique(DF.coords[,'y']);

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

    # crop.extent <- terra::ext(terra::rast(
    #     crs  = terra::crs(SR.target, proj = TRUE),
    #     xmin = 445629.6 - 1e3,
    #     xmax = 445629.6 + 1e3,
    #     ymin = 5030368 - 1e3,
    #     ymax = 5030368 + 1e3
    #     ));

    # SR.cropped <- terra::crop(
    #     x = SR.target,
    #     y = crop.extent
    #     );

    # DF.coords <- terra::crds(SR.cropped);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    # return( c(temp.X,temp.Y) );
    return( SFC.output );

    }

##################################################
