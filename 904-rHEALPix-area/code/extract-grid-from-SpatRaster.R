
extract.grid.from.SpatRaster <- function(
    SR.input = NULL
    ) {

    thisFunctionName <- "extract.grid.from.SpatRaster";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.centroids <- terra::crds(SR.input);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.centroids <- sf::st_as_sf(
        x      = as.data.frame(DF.centroids),
        crs    = sf::st_crs(SR.input),
        coords = c('x','y')
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    x.coords  <- sort(unique(DF.centroids[,'x']));
    y.coords  <- sort(unique(DF.centroids[,'y']));

    x.coords <- x.coords[seq(1,length(x.coords)-1)] + diff(x.coords) / 2; 
    y.coords <- y.coords[seq(1,length(y.coords)-1)] + diff(y.coords) / 2;

    resoln.SR.input <- terra::res(SR.input);

    x.coords <- c(
        min(x.coords) - resoln.SR.input[1],
        x.coords,
        max(x.coords) + resoln.SR.input[1]
        );

    y.coords <- c(
        min(y.coords) - resoln.SR.input[2],
        y.coords,
        max(y.coords) + resoln.SR.input[2]
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    min.x <- min(x.coords);
    max.x <- max(x.coords);

    min.y <- min(y.coords);
    max.y <- max(y.coords);

    list.linestrings <- list();

    for ( i in seq(1,length(x.coords)) ) {
        temp.linestring <- sf::st_linestring(matrix(
            c(x.coords[i],min.y,x.coords[i],max.y),
            ncol  = 2,
            byrow = TRUE
            ));
        list.linestrings <- append(
            list.linestrings,
            list(temp.linestring)
            );
        }

    for ( j in seq(1,length(y.coords)) ) {
        temp.linestring <- sf::st_linestring(matrix(
            c(min.x,y.coords[j],max.x,y.coords[j]),
            ncol  = 2,
            byrow = TRUE
            ));
        list.linestrings <- append(
            list.linestrings,
            list(temp.linestring)
            );
        }

    SF.grid.lines <- sf::st_sfc(
        list.linestrings,
        crs = sf::st_crs(SR.input)
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list(
        centroids  = SF.centroids,
        grid.lines = SF.grid.lines
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.output );

    }
