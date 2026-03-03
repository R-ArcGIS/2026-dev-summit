furl <- "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/ContaminationSites_Baldwin/FeatureServer/3"

pnts <- arc_read(furl, token = NULL) |>
  dplyr::select(-objectid)


furl <- "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/ContaminationSites_Baldwin/FeatureServer/3"

arc_read(furl, token = NULL) |>
  dplyr::select(-objectid) |>
  sf::st_transform(6497) |>
  dplyr::mutate(coords = as.data.frame(st_coordinates(geometry))) |>
  tidyr::unnest(coords) |>
  sf::st_drop_geometry() |>
  readr::write_csv("data/baldwin.csv")


fset <- as_featureset(input)
fset$spatialReference$wkid <- as.integer(fset$spatialReference$wkid)
input_feature <- list(value = fset)
input <- readr::read_csv(
  "data/baldwin.csv"
) |>
  # convert to spatial data frame
  sf::st_as_sf(coords = c("X", "Y"), crs = 6497)
yyjsonr::write_json_str(input_feature, auto_unbox = TRUE) |>
  clipr::write_clip()

# delete_features(
#   arc_open(furl, token = NULL),
#   where = "zipcode = 49304",
#   token = NULL
# )
