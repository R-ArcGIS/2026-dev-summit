# helper
source("validate-endpoint.R")

# read input features
input <- readr::read_csv(
  "data/baldwin.csv"
) |>
  # convert to spatial data frame
  sf::st_as_sf(coords = c("X", "Y"), crs = 6497)

input

# run the validation
validate_gp_inputs(input)
