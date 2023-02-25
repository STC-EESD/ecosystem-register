
test.dggridR <- function(
    resolutions  = seq(0,7,1),
    projection   = "ISEA",
    topology     = "HEXAGON",
    aperture     =    3,
    precision    =   11,
    pole_lat_deg =   37, # 58.28252559,
    pole_lon_deg = -178,  # 11.25
    azimuth_deg  =    0
    ) {

    thisFunctionName <- "test.dggridR";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(dggridR);
    require(sf);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.resolution in resolutions ) {

        LIST.grid.specs <- dggridR::dgconstruct(
            res          = temp.resolution,
            projection   = projection,
            topology     = topology,
            aperture     = aperture,
            precision    = precision,
            pole_lat_deg = pole_lat_deg,
            pole_lon_deg = pole_lon_deg,
            azimuth_deg  = azimuth_deg
            );

        cat("\nstr(LIST.grid.specs)\n");
        print( str(LIST.grid.specs)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.boundaries <- dggridR::dgearthgrid(
            dggs = LIST.grid.specs
            );

        SF.grid.boundaries[,'geometry'] <- sf::st_cast(
            x  = SF.grid.boundaries[,'geometry'],
            to = "LINESTRING"
            );

        SF.grid.boundaries[,'n.vertices'] <- apply(
            X      = SF.grid.boundaries,
            MARGIN = 1,
            FUN    = function(x) { return( length(x$geometry)/2 - 1 ) }
            );

        cat("\nstr(SF.grid.boundaries)\n");
        print( str(SF.grid.boundaries)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.pentagons <- SF.grid.boundaries[SF.grid.boundaries$n.vertices == 5,];
        SF.grid.pentagons[,'geometry'] <- sf::st_cast(
            x  = SF.grid.pentagons[,'geometry'],
            to = "POLYGON"
            );

        cat("\nstr(SF.grid.pentagons)\n");
        print( str(SF.grid.pentagons)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        layer.name <- paste0(
            projection,
            toupper(substr(x = topology, start = 1, stop = 1)),
            aperture,
            'r',
            temp.resolution
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SHP.output <- paste0("grid-",layer.name,".shp");
        sf::st_write(
            obj    = SF.grid.boundaries,
            dsn    = SHP.output,
            layer  = layer.name,
            driver = "ESRI Shapefile"
            );

        SHP.output <- paste0("grid-",layer.name,"-pentagons.shp");
        sf::st_write(
            obj    = SF.grid.pentagons,
            dsn    = SHP.output,
            layer  = layer.name,
            driver = "ESRI Shapefile"
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
