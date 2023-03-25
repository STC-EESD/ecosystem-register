
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
    "generate-rasters-provincial.R"
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
generate.rasters.provincial(
    data.directory   = data.directory,
    output.directory = "rasters-provincial"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# folder.ottawa <- data.directory;
# folder.ottawa <- gsub(x =  folder.ottawa, pattern = "github",   replacement = "gittmp"            );
# folder.ottawa <- gsub(x =  folder.ottawa, pattern = "000-data", replacement = "991-generate-tiffs");
# folder.ottawa <- file.path(folder.ottawa,"output.2023-03-05.01");
# cat("\nfolder.ottawa\n");
# print( folder.ottawa   );

# tiff.files <- list.files(path = folder.ottawa, pattern = "\\.(tif|tiff)$");
# cat("\ntiff.files\n");
# print( tiff.files   );

# TIF.ottawa <- grep(x = tiff.files, pattern = "0717", value = TRUE);

# ottawa.raster  <- terra::rast(x = file.path(folder.ottawa,TIF.ottawa)); 
# cat("\nottawa.raster\n");
# print( ottawa.raster   );

# png(
#     filename = "raster-ottawa-ndvi.png",
#     res    = 300,
#     width  =  12,
#     height =  12,
#     units  = "in"
#     );
# terra::plot(
#     x     = ottawa.raster,
#     col   = NDVI.colour.palette,
#     colNA = colour.NA
#     );
# dev.off();

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# ottawa.raster.reprojected <- terra::project(
#     x = ottawa.raster,
#     y = terra::crs(x = aci.2021.on.raster)
#     );
# cat("\nottawa.raster.reprojected\n");
# print( ottawa.raster.reprojected   );

# cat("\naci.2021.on.raster\n");
# print( aci.2021.on.raster   );

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# aci.2021.ottawa.raster <- terra::crop(
#     x = aci.2021.on.raster,
#     y = ottawa.raster.reprojected
#     ); 
# cat("\naci.2021.ottawa.raster\n");
# print( aci.2021.ottawa.raster   );

# png(
#     filename = "raster-ottawa-aci-2021.png",
#     res    = 300,
#     width  =  12,
#     height =  12,
#     units  = "in"
#     );
# terra::plot(
#     x     = aci.2021.ottawa.raster,
#     # col = NDVI.colour.palette,
#     colNA = colour.NA
#     );
# dev.off();

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# JSN.grid.extent.rHEALPix.planar <- jsonlite::read_json("extent-grid-rHEALPix-planar.json");

# my.raster.template <- terra::rast(
#     crs   = JSN.grid.extent.rHEALPix.planar[['proj4string']],
#     xmin  = JSN.grid.extent.rHEALPix.planar[['xmin'       ]],
#     xmax  = JSN.grid.extent.rHEALPix.planar[['xmax'       ]],
#     ymin  = JSN.grid.extent.rHEALPix.planar[['ymin'       ]],
#     ymax  = JSN.grid.extent.rHEALPix.planar[['ymax'       ]],
#     ncols = JSN.grid.extent.rHEALPix.planar[['ncols'      ]],
#     nrows = JSN.grid.extent.rHEALPix.planar[['nrows'      ]]
#     );

# reprojected.raster <- terra::project(
#     x      = ottawa.raster,
#     y      = my.raster.template,
#     method = "bilinear"
#     );

# cat("\nterra::crs(reprojected.raster)\n");
# print( terra::crs(reprojected.raster)   );

# terra::writeRaster(
#     x        = reprojected.raster,
#     filename = "reprojected-to-rHEALPix-planar.tiff"
#     );

# output.png <- paste0(
#     "raster-reprojected-res-",
#     stringr::str_pad(string = as.character(resolution), width = 2, pad = "0"),
#     ".png");
# png(
#     filename = output.png,
#     res    = 300,
#     width  =  12,
#     height =  12,
#     units  = "in"
#     );
# terra::plot(
#     x     = reprojected.raster,
#     col   = NDVI.colour.palette,
#     colNA = colour.NA
#     );
# dev.off();

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# DF.raster <- as.data.frame(
#     x     = reprojected.raster,
#     xy    = TRUE,
#     na.rm = FALSE
#     ); 

# cat("\nDF.raster\n");
# print( DF.raster   );

# ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# SHP.boundary.centroids <- list.files(pattern = "rHEALPix-planar-boundary-centroids.+\\.shp");
#  SF.boundary.centroids <- sf::st_read(SHP.boundary.centroids);
#  SF.boundary.centroids <- cbind(SF.boundary.centroids,sf::st_coordinates(SF.boundary.centroids));
# sf::st_crs(SF.boundary.centroids) <- proj4string.rHEALPix;

# cat("\nSF.boundary.centroids\n");
# print( SF.boundary.centroids   );

# cat("\nunique(sf::st_drop_geometry(SF.boundary.centroids[,'X']))\n");
# print( unique(sf::st_drop_geometry(SF.boundary.centroids[,'X']))   );

# cat("\nunique(DF.raster[,'x'])\n");
# print( unique(DF.raster[,'x'])   );

# cat("\nunique(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))\n");
# print( unique(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))   );

# cat("\nunique(DF.raster[,'y'])\n");
# print( unique(DF.raster[,'y'])   );

# DF.x.coords <- data.frame(
#     rHEALPixDGGS = unique(unlist(sf::st_drop_geometry(SF.boundary.centroids[,'X']))),
#     reprojected  = unique(DF.raster[,'x'])
#     );
# DF.x.coords[,    'diff'] <- DF.x.coords[,'reprojected'] - DF.x.coords[,'rHEALPixDGGS'];
# DF.x.coords[,'rel.diff'] <- 2 * abs(DF.x.coords[,'diff']) / ( abs(DF.x.coords[,'reprojected']) + abs(DF.x.coords[,'rHEALPixDGGS']) );

# DF.y.coords <- data.frame(
#     rHEALPixDGGS = unique(unlist(sf::st_drop_geometry(SF.boundary.centroids[,'Y']))),
#     reprojected  = unique(DF.raster[,'y'])
#     );
# DF.y.coords[,'diff'] <- DF.y.coords[,'reprojected'] - DF.y.coords[,'rHEALPixDGGS'];
# DF.y.coords[,'rel.diff'] <- 2 * abs(DF.y.coords[,'diff']) / ( abs(DF.y.coords[,'reprojected']) + abs(DF.y.coords[,'rHEALPixDGGS']) );

# cat("\nsummary(DF.x.coords)\n");
# print( summary(DF.x.coords)   );

# cat("\nDF.x.coords\n");
# print( DF.x.coords   );

# cat("\nsummary(DF.y.coords)\n");
# print( summary(DF.y.coords)   );

# cat("\nDF.y.coords\n");
# print( DF.y.coords   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
