# Get subgrid
#
# input:
#  raw-data/EU_grid_XXkm.gpkg
# output:
#  derived-data/EU_subgrid_XXkm_subsize_XXkm.gpkg

library(here)
library(terra)
library(sf)
library(exactextractr)
library(data.table)

# Set resolution ----------------------------------------------------------

# Set the resolution (1, 2, 5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independently, de-comment the following line
# gridsize_km <- "50"
# subgrid_size_km <- 10

gridfile <- paste0("EU_grid_", gridsize_km, "km.gpkg")

# Load the EEA 50km grid with sf (only cells with observation)
grid <- st_read(here("data", "derived-data", gridfile))

# Create subgrid ----------------------------------------------------------
gridsize_km_num <- as.numeric(gridsize_km)

# Get number of splits
n_sub <- gridsize_km_num / subgrid_size_km

# Round grid_size if needed
if (n_sub %% 1 != 0) {
  stop("grid size must be a multiple of subgrid size")
}

# grid to raster
one_cell <- ext(grid[1, ])
cell_res_x <- one_cell$xmax - one_cell$xmin
cell_res_y <- one_cell$ymax - one_cell$ymin

grid_rast <- rast(ext(grid), 
                  resolution = c(cell_res_x / n_sub, cell_res_y / n_sub), crs = crs(grid))

# Pull cell ID to raster
grid_rast <- rasterize(grid, grid_rast, field = "GRD_ID")

# # Assign unique subcell_id
grid_rast_sub <- rast(grid_rast)
values(grid_rast_sub) <- 1:ncell(grid_rast_sub)

# Combine both rasters
grid_rast_sub <- c(grid_rast, grid_rast_sub)
names(grid_rast_sub) <- c("GRD_ID", "subcell_unique_id")

grid_rast_sub <- mask(grid_rast_sub, grid)
subcell_grid <- as.polygons(grid_rast_sub, dissolve = FALSE)

# Assign 1-n_sub^2 id within each cell
# It's okay if the ids are scrambled within cell
subcell_grid_dt <- as.data.table(subcell_grid)
subcell_grid_dt[, subcell_id := 1:.N, by = GRD_ID]

# Add it to the vector
subcell_grid <- merge(subcell_grid, subcell_grid_dt, by = c("GRD_ID", "subcell_unique_id"))

# Export grid -------------------------------------------------------------
gridfile_write <- paste0("EU_subgrid_", gridsize_km, "km_subsize_", round(subgrid_size_km, 1), "km.gpkg")

writeVector(
  subcell_grid,
  here("data", "derived-data", gridfile_write),
  overwrite = TRUE
)