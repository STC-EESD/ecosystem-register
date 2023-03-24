
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
require(terra);

# source supporting R code
code.files <- c(
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

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.rHEALPix <- "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50";
proj4string.epsg4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
folder.tiff <- data.directory;
folder.tiff <- gsub(x = folder.tiff, pattern = "github",   replacement = "gittmp"            );
folder.tiff <- gsub(x = folder.tiff, pattern = "000-data", replacement = "991-generate-tiffs");
folder.tiff <- file.path(folder.tiff,"output.2023-03-05.01");
cat("\nfolder.tiff\n");
print( folder.tiff   );

tiff.files <- list.files(path = folder.tiff, pattern = "\\.(tif|tiff)$");
cat("\ntiff.files\n");
print( tiff.files   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.tiff <- grep(x = tiff.files, pattern = "0717", value = TRUE);
cat("\nmy.tiff\n");
print( my.tiff   );

original.raster  <- terra::rast(x = file.path(folder.tiff,my.tiff));
original.values <- as.data.frame(
    x     = original.raster,
    xy    = TRUE,
    na.rm = FALSE
    ); 
cat("\noriginal.raster\n");
print( original.raster   );

my.extent.original <- terra::ext(x = original.raster);
cat("\nmy.extent.original\n");
print( my.extent.original   );

my.xmin.original <- terra::xmin(my.extent.original);
my.xmax.original <- terra::xmax(my.extent.original);

my.ymin.original <- terra::ymin(my.extent.original);
my.ymax.original <- terra::ymax(my.extent.original);

DF.extent.original <- base::as.data.frame(base::matrix(
    data = c(
        my.xmin.original,my.ymin.original,
        my.xmax.original,my.ymin.original,
        my.xmax.original,my.ymax.original,
        my.xmin.original,my.ymax.original
        ),
    dimnames = list(
        c('xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax'),
        c('x','y')
        ),
    byrow    = TRUE,
    nrow     = 4,
    ncol     = 2
    ));
DF.extent.original[,'label'] <- rownames(DF.extent.original);

SF.extent.original <- sf::st_as_sf(
    x      = DF.extent.original,
    coords = c("x","y"),
    crs    = proj4string.epsg4326
    );

cat("\nSF.extent.original\n");
print( SF.extent.original   );

sf::st_write(
    obj = SF.extent.original,
    dsn = "extent-point-original.shp"
    );

sf::st_write(
    obj = SF.extent.original,
    dsn = "extent-point-original.geojson"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.extent.rHEALPix <- terra::ext(
    x = terra::project(
        x      = original.raster,
        y      = proj4string.rHEALPix,
        method = 'bilinear'
        )
    );

cat("\nmy.extent.rHEALPix\n");
print( my.extent.rHEALPix   );

my.xmin.rHEALPix <- terra::xmin(my.extent.rHEALPix);
my.xmax.rHEALPix <- terra::xmax(my.extent.rHEALPix);

my.ymin.rHEALPix <- terra::ymin(my.extent.rHEALPix);
my.ymax.rHEALPix <- terra::ymax(my.extent.rHEALPix);

DF.extent.rHEALPix <- base::as.data.frame(base::matrix(
    data = c(
        my.xmin.rHEALPix,my.ymin.rHEALPix,
        my.xmax.rHEALPix,my.ymin.rHEALPix,
        my.xmax.rHEALPix,my.ymax.rHEALPix,
        my.xmin.rHEALPix,my.ymax.rHEALPix
        ),
    dimnames = list(
        c('xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax'),
        c('x','y')
        ),
    byrow    = TRUE,
    nrow     = 4,
    ncol     = 2
    ));
DF.extent.rHEALPix[,'label'] <- rownames(DF.extent.rHEALPix);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
SF.extent.rHEALPix <- sf::st_as_sf(
    x      = DF.extent.rHEALPix,
    coords = c("x","y"),
    crs    = proj4string.rHEALPix 
    );

cat("\nSF.extent.rHEALPix\n");
print( SF.extent.rHEALPix   );

sf::st_write(
    obj = SF.extent.rHEALPix,
    dsn = "extent-point-rHEALPix-planar.shp"
    );

sf::st_write(
    obj = SF.extent.rHEALPix,
    dsn = "extent-point-rHEALPix-planar.geojson"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
SF.extent.EPSG.4326 <- sf::st_transform(
    x   = SF.extent.rHEALPix,
    crs = sf::st_crs(4326)
    );

cat("\nSF.extent.EPSG.4326\n");
print( SF.extent.EPSG.4326   );

sf::st_write(
    obj = SF.extent.EPSG.4326,
    dsn = "extent-point-EPSG-4326.shp"
    );

sf::st_write(
    obj = SF.extent.EPSG.4326,
    dsn = "extent-point-EPSG-4326.geojson"
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
