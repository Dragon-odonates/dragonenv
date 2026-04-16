# Format the environmental data
# avoid repeating B2 and B3 for formating issues
# input:
#  derived-data/Bioclim_XXkm.csv
#  derived-data/CLC2018_XXkm.csv
# output:
#  derived-data/Envdata_XXkm.csv

# Set the resolution (1, 2, 5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independently, de-comment the following line
# gridsize_km <- "50"

# 1. Load, format and aggregate CLC data ------------
clcfile <- paste0("CLC2018_", gridsize_km, "km.csv")
clc_grid <- read.csv(here("data", "derived-data", clcfile))
# see the classes and labels from the original data (masked)
# clc <- rast(here("data", "derived-data", "clc_masked", "clc_masked.tif"))
# levels(clc$LABEL3)[[1]]
agg_class <- list(
  "artificial" = c(1:9, 11),
  "agriculture" = 12:22,
  "forest" = 23:25,
  "vegetation" = c(10, 26, 28:29, 32),
  "bare" = c(30, 31, 33, 34),
  "coastal_wetland" = c(37:39, 42, 43),
  "wetland" = c(35, 41),
  "oligotrophic_bogs" = c(27, 36),
  "river" = 40
)

new_clc <- data.frame("GRD_ID" = clc_grid$GRD_ID)

for (i in seq_along(agg_class)) {
  labi <- paste0("frac_", agg_class[[i]])
  if (length(labi) > 1) {
    sumi <- rowSums(clc_grid[, labi]) * 100
  } else {
    sumi <- clc_grid[, labi] * 100
  }
  new_clc <- cbind(new_clc, sumi)
}
colnames(new_clc)[-1] <- paste0("clc_", names(agg_class))

# 2. Load, and format bioclim data ------------
biofile <- paste0("Bioclim_", gridsize_km, "km.csv")
bio_grid <- read.csv(here("data", "derived-data", biofile))
# rename columns to make them more explicit
names(bio_grid) <- gsub("^bio10$", "bio10_temp_warmQ_dC", names(bio_grid))
names(bio_grid) <- gsub("^bio4$", "bio4_annual_sd_temp", names(bio_grid))
names(bio_grid) <- gsub("^bio12$", "bio12_annual_prec_mm", names(bio_grid))
names(bio_grid) <- gsub("^bio15$", "bio15_annual_sd_prec", names(bio_grid))
bio_grid <- as.data.table(bio_grid)

# 3. Get land fractions ------------
land <- ne_countries(continent = "Europe", scale = 10)
land <- st_union(land)
land <- st_transform(land, 3035)
land <- vect(land)

grid <- vect(here("data", "derived-data", paste0("EU_grid_", gridsize_km, "km.gpkg")))
grid <- grid[, "GRD_ID"]

# plot(land)
# plot(grid, add = TRUE)

# Intersect grid with countries
intersection <- intersect(grid, land)
# plot(intersection)

# Compute area of each intersected piece
intersection$area_land <- expanse(intersection, unit = "km")

# Compute area of each original grid cell
grid$area_total <- expanse(grid, unit = "km")

# Aggregate intersected land area back to grid cell ID
land_area <- terra::aggregate(area_land ~ GRD_ID, 
                              data = as.data.frame(intersection), FUN = sum)

# Join back to grid
cover_df <- as.data.frame(grid)
cover_df <- merge(cover_df, land_area, by = "GRD_ID", all.x = TRUE)
cover_df$area_land[is.na(cover_df$area_land)] <- 0

# Calculate percentage
cover_df$percent_land <- (cover_df$area_land/cover_df$area_total)*100
# hist(cover_df$percent_land, breaks = seq(0, 100, by = 5))

# Rename
names(cover_df)[names(cover_df) == "GRD_ID"] <- "grid_id"

# 4. Merge and export ------------

# Environment covariates
new_clc <- as.data.table(new_clc)
out <- new_clc[bio_grid, on = "GRD_ID"]
setnames(out, old = "GRD_ID", new = "grid_id")
out <- as.data.frame(out)
outfile <- paste0("Envdata_", gridsize_km, "km.csv")

write.csv(
  out,
  here("data", "derived-data", outfile),
  row.names = FALSE
)

# Write landcover percentage table
outfile_percent <- paste0("landcover_percent_", gridsize_km, "km.csv")
write.csv(
  cover_df,
  here("data", "derived-data", outfile_percent),
  row.names = FALSE
)

# summary(out)