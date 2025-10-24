# Extract data from Chelsa bioclimatic variables
#
# input:
#  raw-data/EU_grid_XXkm.gpkg
#  raw-data/CHELSA_bio1_1981-2010_V.2.1.tif
#  raw-data/CHELSA_bio10_1981-2010_V.2.1.tif
#  raw-data/CHELSA_bio12_1981-2010_V.2.1.tif
#  raw-data/CHELSA_bio15_1981-2010_V.2.1.tif
#  raw-data/CHELSA_bio4_1981-2010_V.2.1.tif
# output:
#  derived-data/Bioclim_XXkm.csv

# CHELSA
# Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017).
# Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio10_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio12_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio4_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio15_1981-2010_V.2.1.tif

library(terra)
library(sf)
library(exactextractr)

# Set the resolution (5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independantly, de-comment the folloting line
# gridsize_km <- "50"
gridfile <- paste0("EU_grid_", gridsize_km, "km.gpkg")

# Load the EEA 50km grid with terra
grid <- st_read(here("data", "derived-data", gridfile))
# transform to lat/long WGS84
grid_4326 <- st_transform(grid, "EPSG:4326")

# Load the bioclimatic data
chelsa_files <- list.files(
  "data",
  "^CHELSA_",
  recursive = TRUE,
  full.names = TRUE
)

# load all CHELSA file in a rast() object
bio <- rast(chelsa_files)

# make the extraction with terra
bio_grid <- exactextractr::exact_extract(
  bio,
  grid,
  fun = 'mean',
  progress = TRUE,
  append_cols = "cellcode"
)

lab <- sapply(strsplit(chelsa_files, "_"), function(x) x[[2]])
names(bio_grid)[-1] <- lab

# save full extraction
biofile <- paste0("Bioclim_", gridsize_km, "km.csv")
write.csv(
  bio_grid,
  here("data", "derived-data", biofile),
  row.names = FALSE
)
