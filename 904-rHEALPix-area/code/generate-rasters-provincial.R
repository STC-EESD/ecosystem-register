
generate.rasters.provincial <- function(
    DF.aci.crop.classification = NULL,
    data.directory             = NULL,
    data.snapshot              = NULL,
    colour.NA                  = 'black',
    output.directory           = "output-provinces"
    ) {

    thisFunctionName <- "generate.rasters.provincial";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(paths = output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.coltab <- data.frame(code = seq(0,255));
    temp.coltab <- base::merge(
        x     = temp.coltab,
        y     = DF.aci.crop.classification[,c('code','red','green','blue')],
        by    = 'code',
        all.x = TRUE
        );
    temp.coltab[temp.coltab[,'code'] == 0, c('red','green','blue')] <- c(0,0,0);
    colnames(temp.coltab) <- gsub(
        x           = colnames(temp.coltab),
        pattern     = "code",
        replacement = "values"
        );
    temp.coltab[,'alpha'] <- 255;
    temp.coltab <- temp.coltab[,c('red','green','blue','alpha')];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    provincial.abbreviations <- c(
        'bc',
        'ab',
        'sk',
        'mb',
        'on',
        'qc',
        'nb',
        'pe',
        'ns',
        'nl'
        );

    for ( temp.province in provincial.abbreviations ) {

        cat("\n### province:",temp.province,"\n");

        TIF.aci.2021.province <- file.path(
            data.directory,
            data.snapshot,
            paste0("aci_2021_",temp.province,".tif")
            );
        cat("\nTIF.aci.2021.province\n");
        print( TIF.aci.2021.province   );

        temp.raster <- terra::rast(x = TIF.aci.2021.province);
        terra::coltab(temp.raster) <- temp.coltab;
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
