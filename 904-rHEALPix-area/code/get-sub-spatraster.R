
get.sub.spatraster <- function(
    SF.grid.centre = NULL,
    SR.origin      = NULL,
    x.ncell        = NULL,
    y.ncell        = NULL,
    TIF.output     = NULL
    ) {

    thisFunctionName <- "get.sub.spatraster";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    x.res.origin <- terra::xres(x = SR.origin);
    y.res.origin <- terra::yres(x = SR.origin);

    DF.grid.centre <- sf::st_coordinates(x = SF.grid.centre);
    crop.extent <- terra::ext(terra::rast(
        crs  = terra::crs(SR.origin),
        xmin = DF.grid.centre[1,'X'] - x.ncell * x.res.origin,
        xmax = DF.grid.centre[1,'X'] + x.ncell * x.res.origin,
        ymin = DF.grid.centre[1,'Y'] - y.ncell * y.res.origin,
        ymax = DF.grid.centre[1,'Y'] + y.ncell * y.res.origin
        ));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( is.null(TIF.output) ) {

        SR.cropped <- terra::crop(
            x = SR.origin,
            y = crop.extent,
            );

    } else {

        terra::crop(
            x        = SR.origin,
            y        = crop.extent,
            filename = TIF.output
            );
        SR.cropped <- terra::rast(TIF.output);

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SR.cropped );

    }

##################################################
