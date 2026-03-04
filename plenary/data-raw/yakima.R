library(sf)
arc_read(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/Yakima_Spills/FeatureServer/2"
) |>
  sf::st_transform(4326) |>
  dplyr::select(-quantity_imp) |>
  dplyr::mutate(coords = as.data.frame(st_coordinates(geometry))) |>
  tidyr::unnest(coords) |>
  sf::st_drop_geometry() |>
  readr::write_csv("data/yakima.csv")
