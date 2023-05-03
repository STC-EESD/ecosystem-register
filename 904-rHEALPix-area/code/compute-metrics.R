
compute.metrics <- function(
    directory.resample.reproject = NULL,
    output.directory   = "output-metrics",
    crosstab.precision = 7,
    fund.px.area       = 30L * 30L
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
            fund.px.area                 = fund.px.area
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.statistics <- c(
        'area',
        'polygon-statistics'
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
    fund.px.area                 = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.directory <- file.path(original.directory,output.directory,aoi.directory);
    if ( !dir.exists(paths = temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }
    setwd(temp.directory);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.directory <- file.path(original.directory,directory.resample.reproject,aoi.directory);
    tiff.files     <- list.files(path = tiff.directory, pattern = "\\.tiff$");

    for ( temp.tiff in tiff.files ) {
        compute.metrics_SpatRaster.polygon.statistics(
            aoi.directory  = aoi.directory,
            tiff.directory = tiff.directory,
            tiff.file      = temp.tiff,
            fund.px.area   = fund.px.area
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- data.frame();
    CSV.polygon.statistics.files <- list.files(pattern = "-polygon-statistics\\.csv$");
    for ( temp.csv in CSV.polygon.statistics.files ) {
        DF.temp   <- read.csv(file = temp.csv);
        DF.output <- rbind(DF.output,DF.temp);
        }

    write.csv(
        file      = paste0('polygon-statistics-',aoi.directory,'.csv'), 
        x         = DF.output,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    setwd(original.directory);
    return( NULL );

    }

compute.metrics_SpatRaster.polygon.statistics <- function(
    aoi.directory  = NULL,
    tiff.directory = NULL,
    tiff.file      = NULL,
    fund.px.area   = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    PQT.polygons <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = '-polygons.parquet'
        );

    PQT.multipolygons <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = "-multipolygons.parquet"
        );

    PQT.polygons <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = "-polygons.parquet"
        );

    CSV.polygon.statistics <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = "-polygon-statistics.csv"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SR.input <- terra::rast(file.path(tiff.directory,tiff.file));
    list.output <- SpatRaster.to.polygons(
        input.SpatRaster = SR.input,
        factor.colnames  = 'LU2010',
        fund.px.area     = fund.px.area
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # sfarrow::st_write_parquet(
    #     dsn = PQT.multipolygons,
    #     obj = list.output[['SF.multipolygons']]
    #     );

    # sfarrow::st_write_parquet(
    #     dsn = PQT.polygons,
    #     obj = list.output[['SF.polygons']]
    #     );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.polygons <- list.output[['SF.polygons']];

    DF.all.pxsize.classes <- compute.metrics_extract.polygon.statistics(
        SF.input     = SF.polygons,
        fund.px.area = fund.px.area,
        pxsize.class = FALSE
        );
    DF.all.pxsize.classes[,'px.size.class'] <- 'all.px.size.classes';

    leading.colnames    <- c('category','px.size.class');
    reordered.colnames  <- c(leading.colnames,setdiff(colnames(DF.all.pxsize.classes),leading.colnames));
    DF.all.pxsize.classes <- DF.all.pxsize.classes[,reordered.colnames];

    SF.polygons[,'px.size.class'] <- '9 <= n.fund.px';
    SF.polygons[unlist(sf::st_drop_geometry(SF.polygons[,'n.fund.px'])) < 9,'px.size.class'] <- '4 <= n.fund.px < 9';
    SF.polygons[unlist(sf::st_drop_geometry(SF.polygons[,'n.fund.px'])) < 4,'px.size.class'] <- 'n.fund.px < 4';

    DF.by.pxsize.class <- compute.metrics_extract.polygon.statistics(
        SF.input     = SF.polygons,
        fund.px.area = fund.px.area,
        pxsize.class = TRUE
        );

    DF.polygon.statistics <- rbind(DF.all.pxsize.classes,DF.by.pxsize.class);

    base::remove(list = c(
        'DF.all.pxsize.classes',
        'DF.by.pxsize.class'
        ));

    CSV.temp <- paste0(paste(sample(x = c(LETTERS,letters), size = 10), collapse = ""),'.csv');
    write.csv(
        file      = CSV.temp,
        x         = DF.polygon.statistics,
        row.names = FALSE
        );
    DF.polygon.statistics <- read.csv(file = CSV.temp);
    file.remove(CSV.temp);
    colnames(DF.polygon.statistics) <- gsub(
        x           = colnames(DF.polygon.statistics),
        pattern     = "^pl.area_m2.n.polygons$",
        replacement = "n.polygons"
        );
    colnames(DF.polygon.statistics) <- gsub(
        x           = colnames(DF.polygon.statistics),
        pattern     = "^pl.area_m2.n.fund.px$",
        replacement = "n.fund.px"
        );
    colnames(DF.polygon.statistics) <- gsub(
        x           = colnames(DF.polygon.statistics),
        pattern     = "\\.$",
        replacement = "%"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.polygon.statistics[,'aoi'] <- aoi.directory;
    DF.polygon.statistics[,'treatment'] <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = ""
        );

    reordered.colnames <- c('aoi','treatment',setdiff(colnames(DF.polygon.statistics),c('aoi','treatment')));
    DF.polygon.statistics <- DF.polygon.statistics[,reordered.colnames];

    write.csv(
        file      = CSV.polygon.statistics,
        x         =  DF.polygon.statistics,
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    base::remove(list = c(
        'SR.input',
        'SF.polygons',
        'list.output',
        'DF.polygon.statistics'
        ));

    return( NULL );

    }

compute.metrics_extract.polygon.statistics <- function(
    SF.input     = NULL,
    fund.px.area = NULL,
    pxsize.class = FALSE
    ) {

    aggregation.formula    <- "pl.area_m2 ~ category";
    aggregation.formula.gd <- "gd.area_m2 ~ category";
    require.colnames       <- c('category','pl.area_m2');
    require.colnames.gd    <- c('category','gd.area_m2');
    by.variables           <- c('category');

    if ( pxsize.class ) {
        aggregation.formula    <- paste0(aggregation.formula,   " + px.size.class");
        aggregation.formula.gd <- paste0(aggregation.formula.gd," + px.size.class");
        require.colnames       <- c(require.colnames,              'px.size.class');
        require.colnames.gd    <- c(require.colnames.gd,           'px.size.class');
        by.variables           <- c(by.variables,                  'px.size.class');
        }

    DF.class <- stats::aggregate(
        x    = as.formula(aggregation.formula),
        data = sf::st_drop_geometry(SF.input[,require.colnames]),
        FUN  = function(x) {return(c(
            n.polygons = base::length(x),
            n.fund.px  = base::round(x = sum(x) / fund.px.area, digits = 0),
            total      = base::sum(x)
            ))}
        );
    DF.class.gd <- stats::aggregate(
        x    = as.formula(aggregation.formula.gd),
        data = sf::st_drop_geometry(SF.input[,require.colnames.gd]),
        FUN  = function(x) {return(c(
            total      = base::sum(x),
            meean      = base::mean(x),
            min        = base::min(x),
            stats::quantile(x = x, prob = c(0.25,0.50,0.75,0.95)),
            max        = base::max(x)
            ))}
        );

    cat("\nstr(DF.class)\n");
    print( str(DF.class)   );

    cat("\nstr(DF.class.gd)\n");
    print( str(DF.class.gd)   );

    DF.class <- base::merge(
        x  = DF.class,
        y  = DF.class.gd,
        by = by.variables
        );
    base::remove(list = c('DF.class.gd'));

    return( DF.class );

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
        replacement = "n.fund.px"
        ); 
    DF.area[,'pixel.area'] <- as.numeric(as.character(DF.area[,'pixel.area']));
    DF.area[,'total.area'] <- DF.area[,'n.fund.px'] * DF.area[,'pixel.area'];

    DF.area <- DF.area %>%
        dplyr::select( category, n.fund.px , total.area ) %>%
        dplyr::group_by( category ) %>%
        dplyr::summarize( n.fund.px = sum(n.fund.px) , total.area.m2 = sum(total.area) );
    DF.area <- as.data.frame(DF.area);
    DF.area[,'aoi'] <- aoi.directory;
    DF.area[,'treatment'] <- gsub(
        x           = tiff.file,
        pattern     = "\\.tiff",
        replacement = ""
        );

    reordered.colnames <- c('aoi','treatment',setdiff(colnames(DF.area),c('aoi','treatment')));
    DF.area <- DF.area[,reordered.colnames];

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

