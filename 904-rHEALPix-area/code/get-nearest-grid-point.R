
get.nearest.grid.point <- function(
    SF.poi            = NULL,
    SR.target         = NULL,
    point.type        = 'vertex', # 'centroid'
    half.side.length  = 150,
    save.shape.files  = FALSE,
    shape.file.prefix = NULL
    ) {

    thisFunctionName <- "get.nearest.grid.point";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.poi.target.projection <- sf::st_transform(
        x   = SF.poi,
        crs = sf::st_crs(terra::crs(SR.target, proj = TRUE))
        );
    cat("\nSF.poi.target.projection\n");
    print( SF.poi.target.projection   );

    temp.coords <- sf::st_coordinates(SF.poi.target.projection);
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
        list.grid.info <- extract.grid.from.SpatRaster(
            SR.input = SR.cropped
            );
        get.nearest.grid.point_save.shape.files(
            SF.poi            = SF.poi,
            SF.nearest        = SF.output,
            list.grid.info    = list.grid.info,
            shape.file.prefix = shape.file.prefix
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SF.output );

    }

##################################################
get.nearest.grid.point_save.shape.files <- function(
    SF.poi            = NULL,
    SF.nearest        = NULL,
    list.grid.info    = NULL,
    shape.file.prefix = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SHP.epsg.4326.point      <- "point-given.shp";
    SHP.epsg.4326.nearest    <- paste0("point-nearest-grid-point.shp");
    SHP.epsg.4326.centroids  <- "grid-cell-centroids.shp";
    SHP.epsg.4326.grid.lines <- "grid-lines.shp"
    
    if ( !is.null(shape.file.prefix) ) {
        SHP.epsg.4326.point      <- paste0(shape.file.prefix,"-",SHP.epsg.4326.point     );
        SHP.epsg.4326.nearest    <- paste0(shape.file.prefix,"-",SHP.epsg.4326.nearest   );
        SHP.epsg.4326.centroids  <- paste0(shape.file.prefix,"-",SHP.epsg.4326.centroids );
        SHP.epsg.4326.grid.lines <- paste0(shape.file.prefix,"-",SHP.epsg.4326.grid.lines);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(SF.poi) ) {
        SF.poi.epsg.4326 <- sf::st_transform(
            x   = SF.poi,
            crs = sf::st_crs(4326)
            );
        sf::st_write(
            obj = SF.poi.epsg.4326,
            dsn = SHP.epsg.4326.point
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(SF.nearest) ) {
        SF.nearest.epsg.4326 <- sf::st_transform(
            x   = SF.nearest,
            crs = sf::st_crs(4326)
            );
        sf::st_write(
            obj = SF.nearest.epsg.4326,
            dsn = SHP.epsg.4326.nearest
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(list.grid.info) ) {
        SF.centroids <- list.grid.info[['centroids']];
        SF.centroids <- sf::st_transform(
            x   = SF.centroids,
            crs = sf::st_crs(4326)
            );
        sf::st_write(
            obj = SF.centroids,
            dsn = SHP.epsg.4326.centroids
            );
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        SF.grid.lines <- list.grid.info[['grid.lines']];
        SF.grid.lines <- sf::st_transform(
            x   = SF.grid.lines,
            crs = sf::st_crs(4326)
            );
        sf::st_write(
            obj = SF.grid.lines,
            dsn = SHP.epsg.4326.grid.lines
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }
