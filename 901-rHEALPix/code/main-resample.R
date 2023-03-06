
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
new.stack <- raster::projectRaster(
    from   = original.stack,
    crs    = proj4string.rHEALPix,
    method = 'bilinear'
    ); 

new.values <- cbind(
    raster::coordinates(obj = new.stack),
    raster::getValues(  x   = new.stack)
    );

cat("\nraster::crs(new.stack)\n");
print( raster::crs(new.stack)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
proj4string.EPSG.4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs";

new.stack <- raster::projectRaster(
    from   = original.stack,
    crs    = proj4string.EPSG.4326,
    method = 'bilinear'
    ); 

new.extent <- raster::extent(x = new.stack);

cat("\nraster::crs(new.stack) -- EPSG.4326\n");
print( raster::crs(new.stack) );

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
