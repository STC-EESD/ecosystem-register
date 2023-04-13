
SpatRaster.to.polygons <- function(
    input.SpatRaster = NULL
    ) {

    thisFunctionName <- "SpatRaster.to.polygons";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    input.SpatVector <- terra::as.polygons(input.SpatRaster);
    SF.multipolygons <- sf::st_as_sf(input.SpatVector);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.polygons <- sf::st_cast(
        x  = SF.multipolygons[1,"geometry"],
        to = "POLYGON"
        );

    for ( row.index in seq(2,nrow(SF.multipolygons)) ) {
        SF.temp <- sf::st_cast(
            x  = SF.multipolygons[row.index,"geometry"],
            to = "POLYGON"
            );
        SF.polygons <- rbind(SF.polygons,SF.temp);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.polygons[,'area']    <- sf::st_area(SF.polygons[,'geometry']);
    SF.polygons[,'area_m2'] <- unlist(sf::st_drop_geometry(SF.polygons[,'area']));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # SF.polygons[,'centroid'] <- sf::st_centroid(SF.polygons[,'geometry'])

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    reordered.colnames <- colnames(SF.polygons);
    reordered.colnames <- c(setdiff(reordered.colnames,"geometry"),"geometry");
    SF.polygons <- SF.polygons[,reordered.colnames];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SF.polygons );

    }

##################################################
