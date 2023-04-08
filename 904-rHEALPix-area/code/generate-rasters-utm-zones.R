
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


    DF.levels <- data.frame();
    for ( temp.utm.zone in utm.zone.numbers ) {

        cat("\n### UTM Zone:",temp.utm.zone,"\n");

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        temp.dir  <- paste0("LU20.+_u",temp.utm.zone,"$");
        temp.dir <- list.files(
            path    = file.path(data.directory,data.snapshot),
            pattern = temp.dir
            );

        cat("\nfile.path(data.directory,data.snapshot,temp.dir)\n");
        print( file.path(data.directory,data.snapshot,temp.dir)   );

        temp.tiff <- list.files(
            path    = file.path(data.directory,data.snapshot,temp.dir),
            pattern = "\\.tif$"
            );
        cat("\ntemp.tiff\n");
        print( temp.tiff   );

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

        DF.levels <- rbind(
            DF.levels,
            terra::levels(temp.raster)[[1]]
            );
        DF.levels <- unique(DF.levels);

        output.png <- file.path(
            output.directory,
            paste0("raster-utm-zone-",temp.utm.zone,".png")
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
    DF.levels <- DF.levels[order(DF.levels[,'Value']),];
    write.csv(
        x         = DF.levels,
        file      = file.path(output.directory,"DF-levels.csv"),
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
