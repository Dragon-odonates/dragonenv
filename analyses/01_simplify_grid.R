# Transform occurrence data on 50km grid
# usefull for shinyapp (but not needed for further modelling)
# input:
#  raw-data/occ_all.rds
#  raw-data/EEA_50km.gpkg
# output:
#  derived-data/occ_grid_50km.rds
#  derived-data/EU_grid_50km.gpkg
#  derived-data/EU_points_50km.gpkg

## Load Project Addins (R Functions) -------------
library(rnaturalearth)
library(sf)
library(terra)
library(here)

# Set the resolution (5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independantly, de-comment the folloting line
# gridsize_km <- "50"

# List of countries to get the grid for
# fmt: skip
country_list <- c("Austria", "Belgium", "Cyprus", "Czechia",
                  "Denmark", "Finland", "France", "Germany",
                  "Ireland", "Italy", "Luxembourg", "Netherlands",
                  "Norway", "Portugal", "Slovenia", "Spain", 
                  "Sweden", "Switzerland", "United Kingdom")

# get the name of the raw file
raw_file <- list(
  "50" = "EEA_50km_grid_v2024.gpkg",
  "10" = "Grid_ETRS89-LAEA_10K.shp",
  "5" = "5km.shp"
)


# Get EEA 50km grid ---------------------------------------------------------------

# Original file downloaded from https://sdi.eea.europa.eu/catalogue/srv/api/records/aac8379a-5c4e-445c-b2ef-23a6a2701ef0?language=all
g1 <- st_read(here("data", "raw-data", raw_file[gridsize_km]))

# handle GEOMETRYCOLLECTION (in the case of 50km grid)
if (st_geometry_type(g1, by_geometry = FALSE) == "POLYGON") {
  grid <- vect(g1)
} else {
  # transformed from original grid into POLYGON
  g2 <- st_cast(g1, "GEOMETRYCOLLECTION")
  grid <- st_collection_extract(g2, "POLYGON")
  # then convert it to terra::SpatVector object
  grid <- vect(grid)
}

# make sure 'cellcode' is in lower case (avoid the case of 10km grid with CellCode)
names(grid)[tolower(names(grid)) == "cellcode"] <- "cellcode"

# Get countries vectors ---------------------------------------------------

# Get countries borders
countries <- rnaturalearth::ne_countries(country = country_list, scale = 50)

# Crop data to continental Europe
europe_bbox <- c(xmin = -13.0, xmax = 35.7, ymin = 33.8, ymax = 72.0)
countries <- st_crop(countries, europe_bbox)

# Change CRS
countries <- st_transform(countries, 3035)

# Create terra object
countries <- vect(countries)
# no need to aggregate here
# countries_united <- aggregate(countries)

# Crop grid to countries extent -------------------------------------------

# Get grid cells intersecting countries
rel <- is.related(grid, countries, "intersects")

# subsetting the grid
grid_crop <- grid[rel, ]

# plot(grid_crop)
# lines(countries)

# Export grid -------------------------------------------------------------
gridfile_write <- paste0("EU_grid_", gridsize_km, "km.gpkg")

writeVector(
  grid_crop,
  here("data", "derived-data", gridfile_write),
  overwrite = TRUE
)
