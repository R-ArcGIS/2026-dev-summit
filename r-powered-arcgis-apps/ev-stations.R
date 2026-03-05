library(arcgis)
library(dplyr)
library(sf)

# authenticate
set_arc_token(auth_user())

# access the existing ev station data
ev_stations_url <- 'https://services1.arcgis.com/hLJbHVT9ZrDIzK0I/arcgis/rest/services/Stations/FeatureServer/0'
fservice <- arc_open(ev_stations_url)
stations <- arc_select(fservice)
stations

# good news, 18 new stations are planned for nova scotia!
fp <- "New_Stations.csv" # or could use feature class or service
new_stations <- readr::read_csv(fp) |>
  st_as_sf(
    coords = c("Longitude", "Latitude"),
    crs = 4326
  )

# transform to crs of feature service
target_crs <- fservice$spatialReference$latestWkid
new_geoms <- st_transform(new_stations, target_crs)

# reverse geocode? could also switch to geocoding if we populated the addresses instead. just was easier to drop points
geocoded <- reverse_geocode(st_geometry(new_stations))
glimpse(geocoded) # just randomly dropped points so the results are not great

# create the new features, populate any attributes, etc.
new_station <- stations[1,]
new_station$Fuel_Type_Code <- "NEWKIND"
new_station$geometry <- new_geoms[1,]$geometry

# push to feature class
add_res <- add_features(fservice, new_station)
add_res


