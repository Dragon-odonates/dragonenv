#' dragonenv: A Research Compendium
#'
#' @description
#' Spatial analysis of the odonates database
#'
#' @author Romain Frelat, Lisa Nicvert
#' @date 24 Octobre 2025

## Install Dependencies (listed in DESCRIPTION) ----

if (!("remotes" %in% installed.packages())) {
  install.packages("remotes")
}
remotes::install_deps(upgrade = "never")

# Set the resolution  (1, 2, 5, 10, or 50 km)
gridsize_km <- "20"

## Load Project Addins (R Functions) -------------
devtools::load_all()
library(here)

## Run Project ----
# 1 Simplify the grid
message("1. Simplify the grid -------------------------------")
source(here("analyses", "01_simplify_grid.R"))

# 2. Get the land cover
# Corine land cover, 100m, 2018, from
# https://land.copernicus.eu/en/products/corine-land-cover/clc2018
# https://doi.org/10.2909/960998c1-1870-4e82-8051-6485205ebbac
message("2. Get the land cover -------------------------------")
source(here("analyses", "02_get_landcover.R"))

# 3. Get the bioclimatic variables
# Chelsa 2, 1km, average 1981-2010, from
# Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017).
# Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122
# https://chelsa-climate.org
message("3. Get the bioclimatic variables -------------------------------")
source(here("analyses", "03_get_bioclim.R"))

# 4. Get mean yearly temperatures
# All data downloaded in script here: https://www.chelsa-climate.org/datasets/chelsa_monthly
# message("4. Get mean yearly temperatures -------------------------------")
source(here("analyses", "04_get_tempyear.R"))

# 5. Format environmental variables
message("5. Format environmental variables -------------------------------")
source(here("analyses", "05_format_env.R"))
