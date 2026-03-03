# helper
source("validate-endpoint.R")

# read input features
input <- readr::read_csv(
  "data/incidents.csv"
) |>
  # convert to spatial data frame
  sf::st_as_sf(coords = c("X", "Y"), crs = 4326)

input

# run the validation
validate_gp_inputs(input)
