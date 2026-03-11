# reverse geocode
geocoded <- reverse_geocode(st_geometry(new_sf))

to_upload <- geocoded |>
  select(
    Station_Name = place_name,
    Street_Address = address,
    City = city,
    ZIP = postal,
    State = region_abbr,
    Country = country_code
  ) |>
  mutate(Facility_Type = "DevSummit") |>
  st_transform(3857)

to_upload

add_res <- add_features(ev_layer, to_upload)
add_res

# delete the feature
# delete_res <- delete_features(
#   ev_layer,
#   where = "Facility_Type = 'DevSummit'"
# )
