
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

# NDVI.colour.palette <- rev(grDevices::terrain.colors(50));
NDVI.colour.palette   <- grDevices::colorRampPalette(colors = c("gray25","green3"))(51);
NDVI.values           <- seq(-1,1,0.04);

colour.NA <- 'darkorange';

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

cat("\nterra::crs(original.raster)\n");
print( terra::crs(original.raster)   );

png(
    filename = "raster-original.png",
    res    = 300,
    width  =  12,
    height =  12,
    units  = "in"
    );
terra::plot(
    x     = original.raster,
    col   = NDVI.colour.palette,
    colNA = colour.NA
    );
dev.off();

# my.ggplot <- ggplot2::ggplot();
# # my.ggplot <- my.ggplot + ggspatial::layer_spatial(original.raster);
# my.ggplot <- my.ggplot + ggplot2::geom_raster(data = original.raster);
# my.ggplot <- my.ggplot + ggplot2::scale_fill_gradientn(
#     colours  = NDVI.colour.palette,
#     values   = NDVI.values,
#     na.value = colour.NA
#     );

# ggplot2::ggsave(
#     filename = "raster-original-ggplot2.png",
#     plot     = my.ggplot,
#     dpi      = 300,
#     width    =  12,
#     height   =  12,
#     units    = "in"
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
JSN.grid.extent.rHEALPix.planar <- jsonlite::read_json("extent-grid-rHEALPix-planar.json");

my.raster.template <- terra::rast(
    crs   = JSN.grid.extent.rHEALPix.planar[['proj4string']],
    xmin  = JSN.grid.extent.rHEALPix.planar[['xmin'       ]],
    xmax  = JSN.grid.extent.rHEALPix.planar[['xmax'       ]],
    ymin  = JSN.grid.extent.rHEALPix.planar[['ymin'       ]],
    ymax  = JSN.grid.extent.rHEALPix.planar[['ymax'       ]],
    ncols = JSN.grid.extent.rHEALPix.planar[['ncols'      ]],
    nrows = JSN.grid.extent.rHEALPix.planar[['nrows'      ]]
    );

reprojected.raster <- terra::project(
    x      = original.raster,
    y      = my.raster.template,
    method = "bilinear"
    );

cat("\nterra::crs(reprojected.raster)\n");
print( terra::crs(reprojected.raster)   );

terra::writeRaster(
    x        = reprojected.raster,
    filename = "reprojected-to-rHEALPix-planar.tiff"
    );

png(
    filename = "raster-reprojected.png",
    res    = 300,
    width  =  12,
    height =  12,
    units  = "in"
    );
terra::plot(
    x     = reprojected.raster,
    col   = NDVI.colour.palette,
    colNA = colour.NA
    );
dev.off();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.raster <- as.data.frame(
    x     = reprojected.raster,
    xy    = TRUE,
    na.rm = FALSE
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

cat("\nsummary(DF.x.coords)\n");
print( summary(DF.x.coords)   );

cat("\nDF.x.coords\n");
print( DF.x.coords   );

cat("\nsummary(DF.y.coords)\n");
print( summary(DF.y.coords)   );

cat("\nDF.y.coords\n");
print( DF.y.coords   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
