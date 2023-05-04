
get.aci.crop.classification <- function(
    data.directory = NULL,
    data.snapshot  = NULL
    ) {

    thisFunctionName <- "get.aci.crop.classification";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    CSV.aci.crop.classification <- file.path(
        data.directory,
        data.snapshot,
        "aci_crop_classifications_iac_classifications_des_cultures.csv"
        );

    DF.aci.crop.classification <- read.csv(
        file         = CSV.aci.crop.classification,
        fileEncoding = "latin1"
        );
    colnames(DF.aci.crop.classification) <- tolower(colnames(DF.aci.crop.classification));

    DF.aci.crop.classification[,'colour'] <- apply(
        X      = DF.aci.crop.classification[,c('red','green','blue')],
        MARGIN = 1,
        FUN    = function(x) { return( grDevices::rgb(red = x[1], green = x[2], blue = x[3], maxColorValue = 255) ) }
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.aci.crop.classification );

    }

##################################################
