# Extract data from Corine land cover
#
# input:
#  raw-data/EU_grid_XXkm.gpkg
#  raw-data/U2018_CLC2018_V2020_20u1.tif
# output:
#  derived-data/CLC2018_XXkm.csv

library(terra)
library(sf)
library(exactextractr)

# Set the resolution (5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independantly, de-comment the folloting line
# gridsize_km <- "50"
gridfile <- paste0("EU_grid_", gridsize_km, "km.gpkg")

# Load the EEA 50km grid with sf (only cells with observation)
grid <- st_read(here("data", "derived-data", gridfile))

# Load the corine land cover with terra
clc <- rast(here("data", "raw-data", "U2018_CLC2018_V2020_20u1.tif"))

# make the extraction with exactextractr
clc_grid <- exactextractr::exact_extract(
  clc,
  grid,
  fun = 'frac',
  progress = TRUE,
  append_cols = "cellcode"
)

clcfile <- paste0("CLC2018_", gridsize_km, "km.csv")
# save full extraction
write.csv(
  clc_grid,
  here("data", "derived-data", clcfile),
  row.names = FALSE
)
