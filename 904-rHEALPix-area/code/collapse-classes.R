
collapse.classes.AAFC.SDLU <- function(
    SR.input   = NULL,
    TIF.output = NULL
    ) {

    thisFunctionName <- "collapse.classes.AAFC.SDLU";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    terra::app(
        x        = SR.input,
        fun      = collapse.classes.AAFC.SDLU_reclassify,
        filename = TIF.output
        );
    SR.output <- terra::rast(TIF.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    terra::coltab(SR.output) <- collapse.classes.AAFC.SDLU_get.DF.coltab();
    levels(SR.output) <- c(
        "unknown",
        "built-up and artificial surfaces",
        "cropland",
        "inland water bodies",
        "treed areas",
        "grassland and shrubland",
        "wetland",
        "permanent snow and ice",
        "other natural and semi-natural"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    terra::writeRaster(
        x         = SR.output,
        filename  = TIF.output,
        overwrite = TRUE
        );
    SR.output <- terra::rast(TIF.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( SR.output );

    }

##################################################
collapse.classes.AAFC.SDLU_reclassify <- function(x) {
    dplyr::case_when(
        x %in% c(21,22,24,25,28,29,81,82,84,85,88,89) ~ 1,
        x %in% c(51,55) ~ 2,
        x %in% c(31) ~ 3,
        x %in% c(41,42,43,44,47,48,49) ~ 4,
        x %in% c(61,62) ~ 5,
        x %in% c(71) ~ 6,
        .default = 7
        );
    }

collapse.classes.AAFC.SDLU_get.DF.coltab <- function() {

    # DF.coltab <- data.frame(code = seq(0,255));
    # DF.coltab <- base::merge(
    #     x     = DF.coltab,
    #     y     = DF.aci.crop.classification[,c('code','red','green','blue')],
    #     by    = 'code',
    #     all.x = TRUE
    #     );
    # DF.coltab[DF.coltab[,'code'] ==  0, c('red','green','blue')] <-   0 * c(1,1,1);
    # DF.coltab[DF.coltab[,'code'] == 10, c('red','green','blue')] <- 255 * c(1,1,1);
    # colnames(DF.coltab) <- gsub(
    #     x           = colnames(DF.coltab),
    #     pattern     = "code",
    #     replacement = "values"
    #     );
    # DF.coltab[,'alpha'] <- 255;
    # DF.coltab <- DF.coltab[,c('red','green','blue','alpha')];

    # cat("\nDF.coltab\n");
    # print( DF.coltab   );

    DF.coltab <- data.frame(
        red   = c(0,201,  0,  0,  0,255,255,0),
        green = c(0,201,202,  0,255,  0,255,0),
        blue  = c(0,201,202,255,  0,  0,  0,0)
        );

    return( DF.coltab );

    }
