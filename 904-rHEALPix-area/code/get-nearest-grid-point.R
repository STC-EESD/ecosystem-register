
get.nearest.grid.point <- function(
    SF.point         = NULL,
    SR.target        = NULL,
    point.type       = 'vertex', # 'centroid'
    half.side.length = 1e3,
    save.shape.files = FALSE
    ) {

    thisFunctionName <- "get.nearest.grid.point";
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
    x.coords  <- sort(unique(DF.coords[,'x']));
    y.coords  <- sort(unique(DF.coords[,'y']));

    if ( point.type == 'vertex' ) {
        x.coords <- x.coords[seq(1,length(x.coords)-1)] + diff(x.coords) / 2; 
        y.coords <- y.coords[seq(1,length(y.coords)-1)] + diff(y.coords) / 2;
        }

    abs.diff.x <- abs(x.coords - temp.coords[,'X']);
    abs.diff.y <- abs(y.coords - temp.coords[,'Y']);

    temp.X <- x.coords[ which(abs.diff.x == min(abs.diff.x)) ];
    temp.Y <- y.coords[ which(abs.diff.y == min(abs.diff.y)) ];

    SF.output <- sf::st_sfc(
        sf::st_point(x = c(temp.X,temp.Y)),
        crs = sf::st_crs(terra::crs(SR.target, proj = TRUE))
        );
    cat("\nSF.output\n");
    print( SF.output   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( save.shape.files ) {
        get.nearest.grid.point_save.shape.files(
            SF.point   = SF.point,
            SF.nearest = SF.output,
            DF.coords  = DF.coords,
            point.type = point.type
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SF.output );

    }

##################################################
get.nearest.grid.point_save.shape.files <- function(
    SF.point   = NULL,
    SF.nearest = NULL,
    DF.coords  = NULL,
    point.type = NULL
    ) {

    SF.point.epsg.4326 <- sf::st_transform(
        x   = SF.point,
        crs = sf::st_crs(4326)
        );

    sf::st_write(
        obj = SF.point.epsg.4326,
        dsn = "point-given.shp"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.nearest.epsg.4326 <- sf::st_transform(
        x   = SF.nearest,
        crs = sf::st_crs(4326)
        );

    sf::st_write(
        obj = SF.nearest.epsg.4326,
        dsn = paste0("point-nearest-grid-",point.type,".shp")
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.coords <- sf::st_as_sf(
        x      = as.data.frame(DF.coords),
        crs    = sf::st_crs(SF.nearest),
        coords = c('x','y')
        );

    SF.coords <- sf::st_transform(
        x   = SF.coords,
        crs = sf::st_crs(4326)
        );

    sf::st_write(
        obj = SF.coords,
        dsn = "grid-cell-centroids.shp"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    x.coords  <- sort(unique(DF.coords[,'x']));
    y.coords  <- sort(unique(DF.coords[,'y']));

    x.coords <- x.coords[seq(1,length(x.coords)-1)] + diff(x.coords) / 2; 
    y.coords <- y.coords[seq(1,length(y.coords)-1)] + diff(y.coords) / 2;

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
        crs = sf::st_crs(SF.nearest)
        );

    SF.grid.lines <- sf::st_transform(
        x   = SF.grid.lines,
        crs = sf::st_crs(4326)
        );

    sf::st_write(
        obj = SF.grid.lines,
        dsn = "grid-lines.shp"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }
