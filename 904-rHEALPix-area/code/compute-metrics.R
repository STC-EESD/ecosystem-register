
compute.metrics <- function(
    directory.resample.reproject = NULL,
    output.directory             = "output-metrics",
    crosstab.precision           = 7
    ) {

    thisFunctionName <- "compute.metrics";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    original.directory <- normalizePath(getwd());

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(paths = output.directory) ) {
        cat("The directory",output.directory,"already exists; do nothing ...");
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
    } else {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    aoi.directories <- list.files(
        path = file.path(original.directory,directory.resample.reproject)
        );

    cat("\naoi.directories\n");
    print( aoi.directories   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( aoi.directory in aoi.directories ) {
        compute.metrics_area.by.landcover(
            original.directory           = original.directory,
            directory.resample.reproject = directory.resample.reproject,
            aoi.directory                = aoi.directory,
            output.directory             = output.directory,
            crosstab.precision           = crosstab.precision
            );
        compute.metrics_polygon.statistics(
            original.directory           = original.directory,
            directory.resample.reproject = directory.resample.reproject,
            aoi.directory                = aoi.directory,
            output.directory             = output.directory,
            crosstab.precision           = crosstab.precision
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.statistics <- c(
        'area'
        # 'polygon-statistics'
        );

    for ( temp.statistic in temp.statistics  ) {
        compute.metrics_rbind(
            original.directory = original.directory,
            output.directory   = output.directory,
            aoi.directories    = aoi.directories,
            temp.statistic     = temp.statistic
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
compute.metrics_rbind <- function(
    original.directory = NULL,
    output.directory   = NULL,
    aoi.directories    = NULL,
    temp.statistic     = NULL,
    CSV.output         = paste0('DF-',temp.statistic,'.csv')
    ) {

    DF.output <- data.frame();
    for ( aoi.directory in aoi.directories ) {
        temp.dir  <- file.path(original.directory,output.directory,aoi.directory);
        temp.csv  <- file.path(temp.dir,paste0(temp.statistic,"-",aoi.directory,".csv"));
        DF.temp   <- read.csv(file = temp.csv);
        DF.output <- rbind(DF.output,DF.temp);
        }

    write.csv(
        file      = CSV.output, 
        x         = DF.output,
        row.names = FALSE
        );

    return( NULL );

    }

compute.metrics_polygon.statistics <- function(
    original.directory           = NULL,
    directory.resample.reproject = NULL,
    aoi.directory                = NULL,
    output.directory             = NULL,
    crosstab.precision           = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.directory <- file.path(original.directory,output.directory,aoi.directory);
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\ngetwd()\n");
    print( getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.directory <- file.path(original.directory,directory.resample.reproject,aoi.directory);
    tiff.files     <- list.files(path = tiff.directory, pattern = "\\.tiff$");

    for ( temp.tiff in tiff.files ) {
        compute.metrics_crosstab(
            aoi.directory      = aoi.directory,
            tiff.directory     = tiff.directory,
            tiff.file          = temp.tiff,
            crosstab.precision = crosstab.precision
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.aoi.area <- data.frame();

    CSV.area.files <- list.files(pattern = "-area\\.csv$");
    for ( temp.csv in CSV.area.files ) {
        DF.temp     <- read.csv(file = temp.csv);
        DF.aoi.area <- rbind(DF.aoi.area,DF.temp);
        }

    write.csv(
        file      = paste0("area-",aoi.directory,".csv"), 
        x         = DF.aoi.area,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }

compute.metrics_area.by.landcover <- function(
    original.directory           = NULL,
    directory.resample.reproject = NULL,
    aoi.directory                = NULL,
    output.directory             = NULL,
    crosstab.precision           = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.directory <- file.path(original.directory,output.directory,aoi.directory);
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\ngetwd()\n");
    print( getwd()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.directory <- file.path(original.directory,directory.resample.reproject,aoi.directory);
    tiff.files     <- list.files(path = tiff.directory, pattern = "\\.tiff$");

    for ( temp.tiff in tiff.files ) {
        compute.metrics_crosstab(
            aoi.directory      = aoi.directory,
            tiff.directory     = tiff.directory,
            tiff.file          = temp.tiff,
            crosstab.precision = crosstab.precision
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.aoi.area <- data.frame();

    CSV.area.files <- list.files(pattern = "-area\\.csv$");
    for ( temp.csv in CSV.area.files ) {
        DF.temp     <- read.csv(file = temp.csv);
        DF.aoi.area <- rbind(DF.aoi.area,DF.temp);
        }

    write.csv(
        file      = paste0("area-",aoi.directory,".csv"), 
        x         = DF.aoi.area,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }

compute.metrics_crosstab <- function(
    aoi.directory      = NULL,
    tiff.directory     = NULL,
    tiff.file          = NULL,
    crosstab.precision = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SR.input <- terra::rast(file.path(tiff.directory,tiff.file));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    CSV.crosstab <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = "-xtab.csv"
        );

    CSV.area <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = "-area.csv"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    random.string <- paste(
        sample(x = c(LETTERS,letters), size = 10, replace = TRUE),
        collapse = ""
        );

    TIF.cellSize <- paste0("tmp-cellSize-",random.string,".tiff");
    terra::cellSize(
        x         = SR.input,
        filename  = TIF.cellSize
        );
    SR.cellsizes <- terra::rast(TIF.cellSize);

    DF.crosstab  <- terra::crosstab(
        x      = c(SR.cellsizes,SR.input),
        digits = crosstab.precision
        );

    cat("\nstr(DF.crosstab)\n");
    print( str(DF.crosstab)   );
    cat("\nutils::head(x = DF.crosstab, n = 20L)\n");
    print( utils::head(x = DF.crosstab, n = 20L)   );

    write.csv(
        file = CSV.crosstab, 
        x    =  DF.crosstab
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.area <- as.data.frame(DF.crosstab);
    colnames(DF.area) <- gsub(
        x           = colnames(DF.area),
        pattern     = "^area$",
        replacement = "pixel.area"
        ); 
    colnames(DF.area) <- gsub(
        x           = colnames(DF.area),
        pattern     = "^Freq$",
        replacement = "n.pixels"
        ); 
    DF.area[,'pixel.area'] <- as.numeric(as.character(DF.area[,'pixel.area']));
    DF.area[,'total.area'] <- DF.area[,'n.pixels'] * DF.area[,'pixel.area'];

    cat("\nstr(DF.area)\n");
    print( str(DF.area)   );

    DF.area <- DF.area %>%
        dplyr::select( category, n.pixels , total.area ) %>%
        dplyr::group_by( category ) %>%
        dplyr::summarize( n.pixels = sum(n.pixels) , total.area.m2 = sum(total.area) );
    DF.area <- as.data.frame(DF.area);
    DF.area[,'aoi'] <- aoi.directory;
    DF.area[,'treatment'] <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = ""
        );

    reordered.colnames <- c('aoi','treatment',setdiff(colnames(DF.area),c('aoi','treatment')));
    DF.area <- DF.area[,reordered.colnames];

    cat("\nstr(DF.area)\n");
    print( str(DF.area)   );

    cat("\nhead(DF.area)\n");
    print( head(DF.area)   );

    write.csv(
        file      = CSV.area, 
        x         =  DF.area,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    base::file.remove(TIF.cellSize);
    base::remove(list = c(
        "SR.input",
        "SR.cellsizes",
        "DF.crosstab",
        "DF.area"
        ));
    return( NULL );

    }
