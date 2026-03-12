# now geocode the single line address
# return only the best candidate per address
geocoded_results <- find_address_candidates(
  to_geocode$SINGLELINE,
  max_locations = 1
)

# preview the results
geocoded_results |>
  select(
    score,
    match_addr,
    nbrhd,
    city,
  )

library(sf)

# combine back to the original input
to_upload <- to_geocode |>
  mutate(geometry = st_geometry(geocoded_results)) |>
  st_as_sf(crs = 4326)
