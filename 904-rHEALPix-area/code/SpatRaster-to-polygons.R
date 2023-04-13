
SpatRaster.to.polygons <- function(
    input.SpatRaster = NULL,
    factor.colnames  = NULL
    ) {

    thisFunctionName <- "SpatRaster.to.polygons";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    input.SpatVector <- terra::as.polygons(input.SpatRaster);
    SF.multipolygons <- sf::st_as_sf(input.SpatVector);

    for ( temp.colname in factor.colnames ) {
        if ( temp.colname %in% colnames(SF.multipolygons) ) {
            temp.character <- base::as.character(base::unlist(sf::st_drop_geometry(SF.multipolygons[,temp.colname])));
            SF.multipolygons[,temp.colname] <- base::factor(
                x      = temp.character,
                levels = base::sort(base::unique(temp.character))
                );
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.polygons <- SpatRaster.to.polygons_row.to.polygons(
        SF.multipolygons = SF.multipolygons,
        row.index        = 1
        );

    for ( row.index in seq(2,nrow(SF.multipolygons)) ) {
        SF.temp <- SpatRaster.to.polygons_row.to.polygons(
            SF.multipolygons = SF.multipolygons,
            row.index        = row.index
            );
        SF.polygons <- rbind(SF.polygons,SF.temp);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.multipolygons <- SpatRaster.to.polygons_add.area.column(
        SF.input = SF.multipolygons
        );

    SF.polygons <- SpatRaster.to.polygons_add.area.column(
        SF.input = SF.polygons
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.multipolygons <- SpatRaster.to.polygons_reorder.columns(
        SF.input = SF.multipolygons
        );

    SF.polygons <- SpatRaster.to.polygons_reorder.columns(
        SF.input = SF.polygons
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list(
        SF.multipolygons = SF.multipolygons,
        SF.polygons      = SF.polygons
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.output );

    }

##################################################
SpatRaster.to.polygons_row.to.polygons <- function(
    SF.multipolygons = NULL,
    row.index        = NULL
    ) {
    SF.polygons <- sf::st_cast(
        x  = SF.multipolygons[row.index,"geometry"],
        to = "POLYGON"
        );
    DF.selected.row <- sf::st_drop_geometry(SF.multipolygons[row.index,]);
    DF.rows <- base::data.frame(deleteme = base::rep(x = NA, times = base::nrow(SF.polygons)));
    for ( temp.colname in base::colnames(DF.selected.row) ) {
        DF.rows[,temp.colname] <- base::rep(
            x     = DF.selected.row[1,temp.colname],
            times = base::nrow(SF.polygons)
            );
        }
    retained.colnames <- base::setdiff(base::colnames(DF.rows),'deleteme');
    DF.rows <- base::as.data.frame(DF.rows[,retained.colnames]);
    base::colnames(DF.rows) <- retained.colnames;
    SF.output <- sf::st_as_sf(base::cbind(DF.rows,SF.polygons));
    return( SF.output );
    }

SpatRaster.to.polygons_add.area.column <- function(
    SF.input = NULL
    ) {
    SF.output <- SF.input;
    SF.output[,'area']    <- sf::st_area(SF.output[,'geometry']);
    SF.output[,'area_m2'] <- unlist(sf::st_drop_geometry(SF.output[,'area']));
    return( SF.output );
    }

SpatRaster.to.polygons_reorder.columns <- function(
    SF.input = NULL
    ) {
    reordered.colnames <- colnames(SF.input);
    reordered.colnames <- c(setdiff(reordered.colnames,"geometry"),"geometry");
    SF.output <- SF.input[,reordered.colnames];
    return( SF.output );
    }
