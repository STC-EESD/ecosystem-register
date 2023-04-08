
test_get.nearest.grid.point <- function(
    DF.aoi           = NULL,
    data.directory   = NULL,
    data.snapshot    = NULL,
    output.directory = "test-get-nearest-grid-points"
    ) {

    thisFunctionName <- "test_get.nearest.grid.point";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- base::getwd();

    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    base::setwd(output.directory);
    cat("\nbase::getwd()\n");
    print( base::getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.ottawa <- DF.aoi[DF.aoi[,"aoi"] == "ottawa",];
    cat("\nDF.ottawa\n");
    print( DF.ottawa   );

    SF.epsg.4326.ottawa <- sf::st_as_sf(
        x      = DF.ottawa,
        crs    = sf::st_crs(4326),
        coords = c("longitude","latitude")
        );
    cat("\nSF.epsg.4326.ottawa\n");
    print( SF.epsg.4326.ottawa   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.dir  <- paste0("LU2010_u",DF.ottawa[,'utmzone']);
    temp.tiff <- list.files(
        path    = file.path(data.directory,data.snapshot,temp.dir),
        pattern = "\\.tif$"
        );

    TIF.utm.zone <- file.path(
        data.directory,
        data.snapshot,
        temp.dir,
        temp.tiff
        );
    cat("\nTIF.utm.zone\n");
    print( TIF.utm.zone   );

    SR.utm.zone <- terra::rast(x = TIF.utm.zone); 
    cat("\nSR.utm.zone\n");
    print( SR.utm.zone   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SFC.grid.point <- get.nearest.grid.point(
        SF.poi            = SF.epsg.4326.ottawa,
        SR.target         = SR.utm.zone,
        half.side.length  = 150,
        save.shape.files  = TRUE,
        shape.file.prefix = "vertex"
        );

    cat("\nSFC.grid.point\n");
    print( SFC.grid.point   );

    SFC.grid.point <- get.nearest.grid.point(
        SF.poi            = SF.epsg.4326.ottawa,
        SR.target         = SR.utm.zone,
        half.side.length  = 150,
        save.shape.files  = TRUE,
        shape.file.prefix = "centroid"
        );

    cat("\nSFC.grid.point\n");
    print( SFC.grid.point   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    base::setwd(original.directory);
    cat("\nbase::getwd()\n");
    print( base::getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
