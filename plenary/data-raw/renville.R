library(arcgis)
all_points <- arc_read(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1",
  token = NULL
)

all_points |>
  dplyr::mutate(coords = as.data.frame(st_coordinates(geometry))) |>
  tidyr::unnest(coords) |>
  sf::st_drop_geometry() |>
  readr::write_csv("data/incidents.csv")


renville <- arc_read(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations_Renville/FeatureServer/1",
  token = NULL
)

renville |>
  dplyr::mutate(coords = as.data.frame(st_coordinates(geometry))) |>
  tidyr::unnest(coords) |>
  sf::st_drop_geometry() |>
  write_csv("data/renville.csv")
