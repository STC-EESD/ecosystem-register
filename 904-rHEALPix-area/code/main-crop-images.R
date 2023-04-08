
command.arguments   <- commandArgs(trailingOnly = TRUE);
data.directory      <- normalizePath(command.arguments[1]);
code.directory      <- normalizePath(command.arguments[2]);
output.directory    <- normalizePath(command.arguments[3]);
google.drive.folder <- command.arguments[4];
resolution          <- command.arguments[5];

cat("\ndata.directory:",      data.directory,      "\n");
cat("\ncode.directory:",      code.directory,      "\n");
cat("\noutput.directory:",    output.directory,    "\n");
cat("\ngoogle.drive.folder:", google.drive.folder, "\n");
cat("\nresolution:",          resolution,          "\n");

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# set working directory to output directory
setwd( output.directory );

##################################################
require(jsonlite);
require(sf);
require(terra);

# source supporting R code
code.files <- c(
    "extract-grid-from-SpatRaster.R",
    "generate-rasters-provincial.R",
    "generate-rasters-utm-zones.R",
    "generate-extents-aoi.R",
    "get-aci-crop-classification.R",
    "get-nearest-grid-point.R",
    # "get-sub-spatraster.R",
    "test-get-nearest-grid-point.R",
    "test-terra-aggregate.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

is.macOS <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores  <- ifelse(test = is.macOS, yes = 2, no = parallel::detectCores() - 1);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

data.snapshot <-"2023-04-05.01";

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.rHEALPix <- "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50";
proj4string.epsg4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";

# NDVI.colour.palette <- rev(grDevices::terrain.colors(50));
NDVI.colour.palette   <- grDevices::colorRampPalette(colors = c("gray25","green3"))(51);
NDVI.values           <- seq(-1,1,0.04);

colour.NA <- 'black';

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.aoi <- read.csv(
    file = file.path(code.directory,"aoi-semi-decadal-land-use-time-series.csv")
    );

test_get.nearest.grid.point(
    DF.aoi           = DF.aoi,
    data.directory   = data.directory,
    data.snapshot    = data.snapshot,
    output.directory = "test-get-nearest-grid-points"
    );

# test_get.sub.spatraster(
#     DF.aoi           = DF.aoi,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     output.directory = "test-terra-aggregate"
#     );

# test_terra.aggregate(
#     DF.aoi           = DF.aoi,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     output.directory = "test-terra-aggregate"
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# generate.rasters.utm.zones(
#     DF.coltab        = DF.coltab,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     colour.NA        = colour.NA,
#     output.directory = "output-utm-zones"
#     );

# generate.extents.aoi(
#     DF.aoi             = DF.aoi,
#     DF.coltab          = DF.coltab,
#     data.directory     = data.directory,
#     data.snapshot      = data.snapshot,
#     x.ncell            = 1000,
#     y.ncell            = 1000,
#     crosstab.precision =    7,
#     output.directory   = "output-aoi"
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
