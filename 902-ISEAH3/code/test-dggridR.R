
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
        layer.name <- paste0(
            projection,
            toupper(substr(x = topology, start = 1, stop = 1)),
            aperture,
            'r',
            temp.resolution
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.polygons <- dggridR::dgearthgrid(
            dggs = LIST.grid.specs
            );
        cat("\nstr(SF.grid.polygons)\n");
        print( str(SF.grid.polygons)   );

        SHP.output <- paste0("grid-",layer.name,"-polygons.shp");
        sf::st_write(
            obj    = SF.grid.polygons,
            dsn    = SHP.output,
            layer  = layer.name,
            driver = "ESRI Shapefile"
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.boundaries <- SF.grid.polygons;
        SF.grid.boundaries[,'geometry'] <- sf::st_cast(
            x  = SF.grid.boundaries[,'geometry'],
            to = "LINESTRING"
            );
        cat("\nstr(SF.grid.boundaries)\n");
        print( str(SF.grid.boundaries)   );

        SHP.output <- paste0("grid-",layer.name,".shp");
        sf::st_write(
            obj    = SF.grid.boundaries,
            dsn    = SHP.output,
            layer  = layer.name,
            driver = "ESRI Shapefile"
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.polygons[,'boundary'] <- sf::st_cast(
            x  = SF.grid.polygons[,'geometry'],
            to = "LINESTRING"
            );

        SF.grid.polygons[,'n.vertices'] <- apply(
            X      = SF.grid.polygons,
            MARGIN = 1,
            FUN    = function(x) { return( length(x$boundary)/2 - 1 ) }
            );

        SF.grid.pentagons <- SF.grid.polygons[SF.grid.polygons$n.vertices == 5,];
        cat("\nstr(SF.grid.pentagons)\n");
        print( str(SF.grid.pentagons)   );

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
