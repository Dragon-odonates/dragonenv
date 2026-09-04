# Transform occurrence data on 50km grid
# usefull for shinyapp (but not needed for further modelling)
# input:
#  raw-data/grid_xxkm_surf.gpkg
# output:
#  derived-data/EU_grid_xxkm.gpkg

## Load Project Addins (R Functions) -------------
library(rnaturalearth)
library(sf)
library(terra)
library(here)

# Set the resolution (1, 2, 5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independently, de-comment the following line
# gridsize_km <- "20"

# List of countries to get the grid for
# fmt: skip
country_list <- c("Andorra", "Austria", "Belgium", "Cyprus", "Czechia",
                  "Denmark", "Finland", "France", "Germany",
                  "Ireland", "Isle of Man", "Italy", "Liechtenstein", "Luxembourg",
                  "Netherlands", "Northern Cyprus", "Norway", "Portugal", "Slovenia", "Spain",
                  "Sweden", "Switzerland", "United Kingdom")

# get the name of the raw file
raw_file <- paste0("grid_", gridsize_km, "km_surf.gpkg")


# Get grids ---------------------------------------------------------------
# Original file downloaded from https://ec.europa.eu/eurostat/web/gisco/geodata/grids
grid <- vect(here("data", "raw-data", "grid", raw_file))

# Get countries vectors ---------------------------------------------------

# Get countries borders
countries <- rnaturalearth::ne_countries(country = country_list, scale = 10)

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

# ggplot2::ggplot() +
#   ggplot2::geom_sf(data = sf::st_as_sf(grid_crop), fill = "grey", col = NA) +
#   ggplot2::geom_sf(data = sf::st_as_sf(countries), fill = NA, col = "darkgrey")
# 
# plot(grid_crop)
# lines(countries)


# Export grid -------------------------------------------------------------
gridfile_write <- paste0("EU_grid_", gridsize_km, "km.gpkg")

writeVector(
  grid_crop,
  here("data", "derived-data", gridfile_write),
  overwrite = TRUE
)

# Also write countries
writeVector(
  countries,
  here("data", "derived-data", "countries.gpkg"),
  overwrite = TRUE
)
