# Get monthky temperature averages
# Code inspired from https://frbcesab.github.io/spatial-r/chapters/31_toydata_mpl.html#get-climate-data-from-chelsa

devtools::load_all()
# Uncomment here() if run independently
library(here)

# Data --------------------------------------------------------------------
# CHELSA URL template for monthly temperatures
url_monthlytas <- "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/monthly/tas/YYYY/CHELSA_tas_MM_YYYY_V.2.1.tif"

# Set the resolution (5, 10, or 50 km)
# the resolution is set in the make.R file
# if run independantly, de-comment the folloting line
gridsize_km <- "10"


# Get grid ----------------------------------------------------------------
gridfile <- paste0("EU_grid_", gridsize_km, "km.gpkg")
grid <- st_read(here("data", "derived-data", gridfile))

# Query temperature -------------------------------------------------------
startdate <- as.Date("1990-01-01")
enddate <- as.Date("2021-12-31")
dseq <- seq.Date(startdate, enddate, by = "month")

replace_MMYYYY <- function(x, u0) {
  u1 <- gsub("MM", format(x, "%m"), u0)
  u2 <- gsub("YYYY", format(x, "%Y"), u1)
  return(u2)
}

url_list <- sapply(dseq, replace_MMYYYY, url_monthlytas)

# add GDAL Virtual File Systems to make use of COG
full_url <- paste0("/vsicurl/", url_list)

# is much faster with 'vsicurl' (no need to download all data)
chelsa_tas <- terra::rast(full_url)

# Format data -------------------------------------------------------------

# Project grid on raster
grid_4326 <- st_transform(grid, crs = "EPSG:4326")

# Get mean (monthly) temperature by grid cell
mtas <- exactextractr::exact_extract(
  chelsa_tas,
  grid_4326,
  fun = 'mean',
  progress = TRUE,
  append_cols = "cellcode"
)

# Aggregate monthly temperature in yearly temperatures
mtas_dt <- data.table::as.data.table(mtas)
mtas_long <- data.table::melt(mtas_dt, id.vars = 1)

# Get years grouping
pattern <- "mean\\.CHELSA_tas_\\d+_(\\d+)_V\\.2\\.1"
replacement <- "\\1"
mtas_long[, year := gsub(pattern = pattern,
                         replacement = replacement, x = variable)]
# Aggregate
mmtas <- mtas_long[, .(temp_mean = mean(value)), by = .(year, cellcode)]

# Convert to °C
mmtas[, temp_mean := temp_mean - 273.15]

# # Format back to several columns
# mmtas_wide <- data.table::dcast(mmtas, 
#                                 formula = cellcode ~ year, 
#                                 value.var = "temp_mean")
# 
# grid_temp <- grid |> 
#   dplyr::left_join(mmtas_wide, by = "cellcode")


# Export ------------------------------------------------------------------
write.csv(mmtas,
          here::here("data", "derived-data", 
                     paste0("CHELSA_yearly_tas_",
                            gridsize_km , "km.csv")),
          row.names = FALSE)
