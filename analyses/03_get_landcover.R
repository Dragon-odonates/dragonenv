# Extract data from Corine land cover
#
# input:
#  raw-data/EU_grid_XXkm.gpkg
#  raw-data/U2018_CLC2018_V2020_20u1.tif
# output:
#  derived-data/CLC2018_XXkm.csv

library(here)
library(terra)
library(sf)
library(exactextractr)

# Mask sea ----------------------------------------------------------------

# # Load CLC with terra
# clc <- rast(here("data", "raw-data",
#                  "u2018_clc2018_v2020_20u1_raster100m", "DATA",
#                  "U2018_CLC2018_V2020_20u1.tif"))
# # This is long but shows 128 values are the high sea, so we can mask it
# # clc128 <- clc == 128
# # plot(clc128)
# 
# # Get values to mask
# clc_mask <- clc %in% c(44, 48, NA, NaN, 128)
# # plot(clc_mask)
# 
# # Mask CLC with countries (remove sea and unused landcover values)
# clc <- terra::mask(clc, clc_mask,
#                    maskvalues = TRUE, updatevalue = NA)
# 
# terra::writeRaster(clc,
#                    here("data", "derived-data", "clc_masked", "clc_masked.tif"),
#                    overwrite = TRUE)

# Set resolution ----------------------------------------------------------

# Set the resolution (1, 2, 5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independently, de-comment the following line
# gridsize_km <- "50"

gridfile <- paste0("EU_grid_", gridsize_km, "km.gpkg")
subgridfile <- paste0("EU_subgrid_", gridsize_km, "km_subsize_", round(subgrid_size_km, 1), "km.gpkg")

# Load the EEA grid with sf
grid <- st_read(here("data", "derived-data", gridfile))

# # Load the subgrid
# subgrid <- st_read(here("data", "derived-data", subgridfile))

# Load masked CLC ---------------------------------------------------------
clc <- rast(here("data", "derived-data", "clc_masked", "clc_masked.tif"))

# make the extraction with exactextractr
clc_grid <- exactextractr::exact_extract(
  clc,
  grid,
  fun = 'frac',
  progress = TRUE,
  append_cols = "GRD_ID"
)

# # make the extraction with exactextractr
# clc_subgrid <- exactextractr::exact_extract(
#   clc,
#   subgrid,
#   fun = 'max',
#   progress = TRUE,
#   append_cols = c("GRD_ID", "subcell_unique_id", "subcell_id")
# )

clcfile <- paste0("CLC2018_", gridsize_km, "km.csv")
# save full extraction
write.csv(
  clc_grid,
  here("data", "derived-data", clcfile),
  row.names = FALSE
)
