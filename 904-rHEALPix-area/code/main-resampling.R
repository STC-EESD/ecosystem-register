
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
    "get-aci-crop-classification.R",
    "perform-resampling.R"
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
DF.coltab.SDLU <- read.csv(file.path(code.directory,"classes-collapsed-SDLU.csv"));
DF.coltab.SDLU[,'col'] <- toupper(DF.coltab.SDLU[,'col']);
DF.coltab.SDLU <- cbind(
    DF.coltab.SDLU,
    t(grDevices::col2rgb(col = DF.coltab.SDLU[,'col']))
    );
cat("\nstr(DF.coltab.SDLU)\n");
print( str(DF.coltab.SDLU)   );
cat("\nDF.coltab.SDLU\n");
print( DF.coltab.SDLU   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
perform.resampling(
    directory.aoi       = "output-aoi",
    output.directory    = "output-resampling",
    WKT.NAD_1983_Albers = WKT.NAD_1983_Albers,
    DF.coltab.SDLU      = DF.coltab.SDLU,
    colour.NA           = 'black'
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
