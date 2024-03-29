
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
require(sfarrow);
require(stringr);
require(terra);

# source supporting R code
code.files <- c(
    "collapse-classes.R",
    "extract-grid-from-SpatRaster.R",
    "generate-rasters-provincial.R",
    "generate-rasters-utm-zones.R",
    "generate-extents-aoi.R",
    "get-aci-crop-classification.R",
    "get-nearest-grid-point.R",
    "get-sub-spatraster.R",
    "SpatRaster-to-polygons.R",
    "test-get-nearest-grid-point.R",
    "test-SpatRaster-to-polygons.R",
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
n.cores  <- ifelse(test = is.macOS, yes =  2, no = parallel::detectCores() - 1);
n.cells  <- ifelse(test = is.macOS, yes = 30, no = 1800);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

data.snapshot            <- "2023-04-05.01";
data.snapshot.boundaries <- "2022-12-19.01";

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.rHEALPix <- "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50";
proj4string.epsg4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";
WKT.NAD_1983_Albers  <- 'PROJCS["NAD_1983_Albers",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",-91.867],PARAMETER["Standard_Parallel_1",49.0],PARAMETER["Standard_Parallel_2",77.0],PARAMETER["Latitude_Of_Origin",63.5],UNIT["Meter",1.0]]'
# temp.SpatRaster <- terra::project(x = my.SpatRaster, y = WKT.NAD_1983_Albers, method = "mode", res = 60)

# NDVI.colour.palette <- rev(grDevices::terrain.colors(50));
NDVI.colour.palette   <- grDevices::colorRampPalette(colors = c("gray25","green3"))(51);
NDVI.values           <- seq(-1,1,0.04);

colour.NA <- 'black';

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.aoi <- read.csv(
    file = file.path(code.directory,"aoi-semi-decadal-land-use-time-series.csv")
    );
DF.aoi[,'utmzone'] <- stringr::str_pad(
    string = as.character(DF.aoi[,'utmzone']),
    pad    = "0",
    side   = "left",
    width  = 2,
    );
print( str(DF.aoi) );
print( DF.aoi );

SF.canada <- sf::st_read(
    dsn = file.path(data.directory,data.snapshot.boundaries,"lpr_000a21a_e","lpr_000a21a_e.shp")
    );
SF.provinces <- SF.canada;
SF.provinces$PRUID <- as.integer(SF.provinces$PRUID);
SF.provinces <- SF.provinces[SF.provinces$PRUID < 60,]
cat("\nstr(SF.provinces)\n");
print( str(SF.provinces)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# test_get.nearest.grid.point(
#     DF.aoi           = DF.aoi,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     output.directory = "test-get-nearest-grid-points"
#     );

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
#     point.type       = 'vertex',
#     x.ncell          = 12,
#     y.ncell          = 12,
#     output.directory = "test-terra-aggregate"
#     );

# test_SpatRaster.to.polygons(
#     DF.aoi           = DF.aoi,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     point.type       = 'vertex',
#     x.ncell          = 180,
#     y.ncell          = 180,
#     output.directory = "test-SpatRaster-to-polygons"
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# generate.rasters.utm.zones(
#     DF.coltab        = DF.coltab,
#     data.directory   = data.directory,
#     data.snapshot    = data.snapshot,
#     colour.NA        = colour.NA,
#     output.directory = "output-utm-zones"
#     );

generate.extents.aoi(
    DF.aoi             = DF.aoi,
    SF.provinces       = SF.provinces,
    DF.coltab          = DF.coltab,
    data.directory     = data.directory,
    data.snapshot      = data.snapshot,
    x.ncell            = n.cells, # 30, # 1000,
    y.ncell            = n.cells, # 30, # 1000,
    crosstab.precision =  7,
    colour.NA          = 'black',
    output.directory   = "output-aoi"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
