
command.arguments   <- commandArgs(trailingOnly = TRUE);
data.directory      <- normalizePath(command.arguments[1]);
code.directory      <- normalizePath(command.arguments[2]);
output.directory    <- normalizePath(command.arguments[3]);
google.drive.folder <- command.arguments[4];

cat("\ndata.directory:",      data.directory,      "\n");
cat("\ncode.directory:",      code.directory,      "\n");
cat("\noutput.directory:",    output.directory,    "\n");
cat("\ngoogle.drive.folder:", google.drive.folder, "\n");

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# set working directory to output directory
setwd( output.directory );

##################################################
require(jsonlite);
require(raster);

# source supporting R code
code.files <- c(
    # "getPyModule-ee.R",
    # "test-ee-Authenticate.R",
    # "test-ee-batch-export.R",
    # "test-googledrive.R"
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

original.stack  <- raster::stack(x = file.path(folder.tiff,my.tiff)); 
original.values <- cbind(
    raster::coordinates(obj = original.stack),
    raster::getValues(  x   = original.stack)
    ); 

cat("\nraster::crs(original.stack)\n");
print( raster::crs(original.stack)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.rHEALPix <- "+proj=rhealpix -f '%.2f' +ellps=WGS84 +south_square=0 +north_square=0 +lon_0=-50";

my.extent.rHEALPix <- raster::projectExtent(
    object = original.stack,
    crs    = proj4string.rHEALPix
    );

cat("\nraster::crs(my.extent.rHEALPix)\n");
print( raster::crs(my.extent.rHEALPix)   );

cat("\nmy.extent.rHEALPix\n");
print( my.extent.rHEALPix   );

my.xmin.rHEALPix <- raster::xmin(raster::extent(my.extent.rHEALPix));
my.xmax.rHEALPix <- raster::xmax(raster::extent(my.extent.rHEALPix));

my.ymin.rHEALPix <- raster::ymin(raster::extent(my.extent.rHEALPix));
my.ymax.rHEALPix <- raster::ymax(raster::extent(my.extent.rHEALPix));

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

SF.extent.rHEALPix <- sf::st_as_sf(
    x      = DF.extent.rHEALPix,
    coords = c("x","y"),
    crs    = proj4string.rHEALPix 
    );

SF.extent.EPSG.4326 <- sf::st_transform(
    x   = SF.extent.rHEALPix,
    crs = sf::st_crs(4326)
    );

sf::st_write(
    obj = SF.extent.EPSG.4326,
    dsn = "my-extent-EPSG-4326.shp"
    );

sf::st_write(
    obj = SF.extent.EPSG.4326,
    dsn = "my-extent-EPSG-4326.geojson"
    );

my.raster.rHEALPix <- raster::projectRaster(
    from   = original.stack,
    crs    = proj4string.rHEALPix,
    method = 'bilinear'
    ); 

my.values.rHEALPix <- cbind(
    raster::coordinates(obj = my.raster.rHEALPix),
    raster::getValues(  x   = my.raster.rHEALPix)
    );

cat("\nraster::crs(my.raster.rHEALPix)\n");
print( raster::crs(my.raster.rHEALPix)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.EPSG.4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";

my.raster.rHEALPix <- raster::projectRaster(
    from   = original.stack,
    crs    = proj4string.EPSG.4326,
    method = 'bilinear'
    ); 

new.extent <- raster::extent(x = my.raster.rHEALPix);

cat("\nraster::crs(my.raster.rHEALPix) -- EPSG.4326\n");
print( raster::crs(my.raster.rHEALPix) );

cat("\nnew.extent -- EPSG.4326\n");
print( new.extent );

list.new.extent <- list(
    'xmin' = new.extent@xmin, 
    'xmax' = new.extent@xmax, 
    'ymin' = new.extent@ymin,
    'ymax' = new.extent@ymax
    );

new.json <- jsonlite::toJSON(list.new.extent) ;

cat("\nnew.json -- EPSG.4326\n");
print( new.json );

# jsonlite::write_json(
#     x    = new.json,
#     path = "extent.json"
#     );

base::write(x = new.json, file = "extent.json");

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
