
generate.rasters.utm.zones <- function(
    DF.coltab        = NULL,
    data.directory   = NULL,
    data.snapshot    = NULL,
    colour.NA        = 'black',
    output.directory = "output-utm-zones"
    ) {

    thisFunctionName <- "generate.rasters.utm.zones";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    utm.zone.numbers <- stringr::str_pad(
        string = as.character(seq(7,22)),
        width  = 2,
        pad    = "0"
        ); 

    for ( temp.zone.number in utm.zone.numbers ) {

        cat("\n### UTM Zone:",temp.zone.number,"\n");

        temp.dir  <- paste0("LU2020_u",temp.zone.number);
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

        temp.raster <- terra::rast(x = TIF.utm.zone);
        # terra::coltab(temp.raster) <- DF.coltab;
        cat("\ntemp.raster\n");
        print( temp.raster   );

        output.png <- file.path(
            output.directory,
            paste0("raster-utm-zone-",temp.zone.number,".png")
            );

        png(
            filename = output.png,
            res      = 300,
            width    =   6,
            height   =  12,
            units    = "in"
            );
        terra::plot(
            x      = temp.raster,
            colNA  = colour.NA,
            legend = FALSE
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
