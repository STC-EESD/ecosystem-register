
test.dggridR <- function(
    resolutions  = seq(0,7,1),
    projection   = "ISEA",
    topology     = "HEXAGON",
    aperture     =    3,
    precision    =   11,
    pole_lat_deg =   37, # 58.28252559,
    pole_lon_deg = -178  # 11.25
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
            pole_lon_deg = pole_lon_deg
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

        cat("\nstr(SF.grid.boundaries)\n");
        print( str(SF.grid.boundaries)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        layer.name <- paste0(
            projection,
            toupper(substr(x = topology, start = 1, stop = 1)),
            aperture,
            'r',
            temp.resolution
            );

        SHP.output <- paste0("grid-",layer.name,".shp");

        sf::st_write(
            obj    = SF.grid.boundaries,
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
