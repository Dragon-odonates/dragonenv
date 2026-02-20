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
  "vegetation" = c(10, 26:29, 32),
  "bare" = c(30, 31, 33, 34),
  "coastal_wetland" = c(37:39, 42, 43),
  "wetland" = c(35, 36, 41),
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
names(bio_grid) <- gsub("^bio12$", "bio12_annual_prec_mm", names(bio_grid))
names(bio_grid) <- gsub("^bio4$", "bio4_sd_temp", names(bio_grid))

# 3. Merge and export ------------
# table(new_clc$GRD_ID == bio_grid$GRD_ID)
out <- cbind(new_clc, bio_grid[, -1])

outfile <- paste0("Envdata_", gridsize_km, "km.csv")
write.csv(
  out,
  here("data", "derived-data", outfile),
  row.names = FALSE
)

# summary(out)