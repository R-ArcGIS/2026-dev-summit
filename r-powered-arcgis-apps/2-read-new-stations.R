library(sf)
library(dplyr)
library(arcgis)

# authenticate
set_arc_token(auth_user())

# get user info for token
self <- arc_user_self()

# preview groups
select(self$groups, id, title, snippet)

# get group item
group <- arc_group("857070a5ce37454ea0ead28075efb304")
group

all_group_items <- arc_group_content(group)

# preview group items
all_group_items |>
  select(title, type, owner)

# filter to only csvs
all_csvs <- all_group_items |>
  filter(type == "CSV") |>
  select(id, name)

# get the portal item for the csv
csv_portal_item <- all_csvs |>
  filter(name == "new-stations.csv") |>
  pull(id) |>
  arc_open()

csv_portal_item

# get the data for it
new_ev_stations_raw <- arc_item_data(csv_portal_item) |>
  # convert to character vector
  rawToChar() |>
  # read to csv
  readr::read_csv()

new_sf <- new_ev_stations_raw |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# view with existing
maplibre(style = basemap) |>
  add_circle_layer(id = "existing", all_stations, circle_color = "#6b0aac") |>
  add_circle_layer(id = "new", new_sf, circle_color = "#fca421")
