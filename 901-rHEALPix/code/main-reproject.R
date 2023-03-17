
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
require(raster);
require(sf);

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

original.stack  <- raster::stack(x = file.path(folder.tiff,my.tiff)); 
original.values <- cbind(
    raster::coordinates(obj = original.stack),
    raster::getValues(  x   = original.stack)
    ); 

cat("\nraster::crs(original.stack)\n");
print( raster::crs(original.stack)   );

png(
    filename = "raster-original.png",
    res    = 300,
    width  =  16,
    height =  16,
    units  = "in"
    );
raster::plot(x = original.stack);
dev.off();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
JSN.grid.extent.rHEALPix.planar <- jsonlite::read_json("extent-grid-rHEALPix-planar.json");

my.raster.template <- raster::raster(
    crs   = JSN.grid.extent.rHEALPix.planar[['proj4string']],
    xmn   = JSN.grid.extent.rHEALPix.planar[['xmin'       ]],
    xmx   = JSN.grid.extent.rHEALPix.planar[['xmax'       ]],
    ymn   = JSN.grid.extent.rHEALPix.planar[['ymin'       ]],
    ymx   = JSN.grid.extent.rHEALPix.planar[['ymax'       ]],
    ncols = JSN.grid.extent.rHEALPix.planar[['ncols'      ]],
    nrows = JSN.grid.extent.rHEALPix.planar[['nrows'      ]]
    );

reprojected.stack <- raster::projectRaster(
    from   = original.stack,
    to     = my.raster.template,
    method = "bilinear"
    );

cat("\nraster::crs(reprojected.stack)\n");
print( raster::crs(reprojected.stack)   );

raster::writeRaster(
    x        = reprojected.stack,
    filename = "reprojected-to-rHEALPix-planar.tiff"
    );

png(
    filename = "raster-reprojected.png",
    res    = 300,
    width  =  16,
    height =  16,
    units  = "in"
    );
raster::plot(x = reprojected.stack);
dev.off();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.raster <- cbind(
    raster::coordinates(reprojected.stack),
    raster::values(     reprojected.stack)
    );

colnames(DF.raster) <- gsub(
    x           = colnames(DF.raster),
    pattern     = "^$",
    replacement = "value"
    );

cat("\nDF.raster\n");
print( DF.raster   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
SHP.boundary.centroids <- list.files(pattern = "rHEALPix-planar-boundary-centroids.+\\.shp");
 SF.boundary.centroids <- sf::st_read(SHP.boundary.centroids);
 SF.boundary.centroids <- cbind(SF.boundary.centroids,sf::st_coordinates(SF.boundary.centroids));
sf::st_crs(SF.boundary.centroids) <- proj4string.rHEALPix;

cat("\nSF.boundary.centroids\n");
print( SF.boundary.centroids   );

cat("\nunique(sf::st_drop_geometry(SF.boundary.centroids[,'X']))\n");
print( unique(sf::st_drop_geometry(SF.boundary.centroids[,'X']))   );

cat("\nunique(DF.raster[,'x'])\n");
print( unique(DF.raster[,'x'])   );

cat("\nunique(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))\n");
print( unique(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))   );

cat("\nunique(DF.raster[,'y'])\n");
print( unique(DF.raster[,'y'])   );

DF.x.coords <- data.frame(
    rHEALPixDGGS = unique(unlist(sf::st_drop_geometry(SF.boundary.centroids[,'X']))),
    reprojected  = unique(DF.raster[,'x'])
    );
DF.x.coords[,    'diff'] <- DF.x.coords[,'reprojected'] - DF.x.coords[,'rHEALPixDGGS'];
DF.x.coords[,'rel.diff'] <- 2 * abs(DF.x.coords[,'diff']) / ( abs(DF.x.coords[,'reprojected']) + abs(DF.x.coords[,'rHEALPixDGGS']) );

DF.y.coords <- data.frame(
    rHEALPixDGGS = unique(unlist(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))),
    reprojected  = unique(DF.raster[,'y'])
    );
DF.y.coords[,'diff'] <- DF.y.coords[,'reprojected'] - DF.y.coords[,'rHEALPixDGGS'];
DF.y.coords[,'rel.diff'] <- 2 * abs(DF.y.coords[,'diff']) / ( abs(DF.y.coords[,'reprojected']) + abs(DF.y.coords[,'rHEALPixDGGS']) );

cat("\nDF.x.coords\n");
print( DF.x.coords   );

cat("\nDF.y.coords\n");
print( DF.y.coords   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# my.extent.rHEALPix <- raster::projectExtent(
#     object = original.stack,
#     crs    = proj4string.rHEALPix
#     );

# cat("\nraster::crs(my.extent.rHEALPix)\n");
# print( raster::crs(my.extent.rHEALPix)   );

# cat("\nmy.extent.rHEALPix\n");
# print( my.extent.rHEALPix   );

# my.xmin.rHEALPix <- raster::xmin(raster::extent(my.extent.rHEALPix));
# my.xmax.rHEALPix <- raster::xmax(raster::extent(my.extent.rHEALPix));

# my.ymin.rHEALPix <- raster::ymin(raster::extent(my.extent.rHEALPix));
# my.ymax.rHEALPix <- raster::ymax(raster::extent(my.extent.rHEALPix));

# DF.extent.rHEALPix <- base::as.data.frame(base::matrix(
#     data = c(
#         my.xmin.rHEALPix,my.ymin.rHEALPix,
#         my.xmax.rHEALPix,my.ymin.rHEALPix,
#         my.xmax.rHEALPix,my.ymax.rHEALPix,
#         my.xmin.rHEALPix,my.ymax.rHEALPix
#         ),
#     dimnames = list(
#         c('xmin_ymin','xmax_ymin','xmax_ymax','xmin_ymax'),
#         c('x','y')
#         ),
#     byrow    = TRUE,
#     nrow     = 4,
#     ncol     = 2
#     ));
# DF.extent.rHEALPix[,'label'] <- rownames(DF.extent.rHEALPix);

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# SF.extent.rHEALPix <- sf::st_as_sf(
#     x      = DF.extent.rHEALPix,
#     coords = c("x","y"),
#     crs    = proj4string.rHEALPix 
#     );

# cat("\nSF.extent.rHEALPix\n");
# print( SF.extent.rHEALPix   );

# sf::st_write(
#     obj = SF.extent.rHEALPix,
#     dsn = "extent-point-rHEALPix-planar.shp"
#     );

# sf::st_write(
#     obj = SF.extent.rHEALPix,
#     dsn = "extent-point-rHEALPix-planar.geojson"
#     );

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# SF.extent.EPSG.4326 <- sf::st_transform(
#     x   = SF.extent.rHEALPix,
#     crs = sf::st_crs(4326)
#     );

# cat("\nSF.extent.EPSG.4326\n");
# print( SF.extent.EPSG.4326   );

# sf::st_write(
#     obj = SF.extent.EPSG.4326,
#     dsn = "extent-point-EPSG-4326.shp"
#     );

# sf::st_write(
#     obj = SF.extent.EPSG.4326,
#     dsn = "extent-point-EPSG-4326.geojson"
#     );

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# my.raster.rHEALPix <- raster::projectRaster(
#     from   = original.stack,
#     crs    = proj4string.rHEALPix,
#     method = 'bilinear'
#     ); 

# my.values.rHEALPix <- cbind(
#     raster::coordinates(obj = my.raster.rHEALPix),
#     raster::getValues(  x   = my.raster.rHEALPix)
#     );

# cat("\nraster::crs(my.raster.rHEALPix)\n");
# print( raster::crs(my.raster.rHEALPix)   );

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# my.raster.rHEALPix <- raster::projectRaster(
#     from   = original.stack,
#     crs    = proj4string.epsg4326,
#     method = 'bilinear'
#     ); 

# new.extent <- raster::extent(x = my.raster.rHEALPix);

# cat("\nraster::crs(my.raster.rHEALPix) -- EPSG.4326\n");
# print( raster::crs(my.raster.rHEALPix) );

# cat("\nnew.extent -- EPSG.4326\n");
# print( new.extent );

# list.new.extent <- list(
#     'xmin' = new.extent@xmin, 
#     'xmax' = new.extent@xmax, 
#     'ymin' = new.extent@ymin,
#     'ymax' = new.extent@ymax
#     );

# new.json <- jsonlite::toJSON(list.new.extent) ;

# cat("\nnew.json -- EPSG.4326\n");
# print( new.json );

# # jsonlite::write_json(
# #     x    = new.json,
# #     path = "extent.json"
# #     );

# base::write(x = new.json, file = "extent.json");

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
