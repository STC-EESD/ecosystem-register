
generate.rasters.provincial <- function(
    data.directory   = NULL,
    output.directory = "rasters-provincial"
    ) {

    thisFunctionName <- "generate.rasters.provincial";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    provincial.abbreviations <- c(
        'bc',
        'ab',
        'sk',
        'mb',
        'on',
        'qc',
        'ns',
        'nb',
        'nl',
        'pe'
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.province in provincial.abbreviations ) {

        cat("\n### province:",temp.province,"\n");

        TIF.aci.2021.province <- file.path(
            data.directory,
            "2023-03-21.01",
            paste0("aci_2021_",temp.province),
            paste0("aci_2021_",temp.province,".tif")
            );
        cat("\nTIF.aci.2021.province\n");
        print( TIF.aci.2021.province   );

        temp.raster <- terra::rast(x = TIF.aci.2021.province); 
        cat("\ntemp.raster\n");
        print( temp.raster   );

        output.png <- file.path(
            output.directory,
            paste0("raster-aci-2021-",temp.province,".png")
            );

        png(
            filename = output.png,
            res      = 300,
            width    =  12,
            height   =   8,
            units    = "in"
            );
        terra::plot(
            x     = temp.raster,
            # col = NDVI.colour.palette,
            colNA = colour.NA
            );
        dev.off();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
