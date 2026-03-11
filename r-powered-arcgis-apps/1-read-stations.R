library(mapgl)
library(arcgis)

# authenticate to AGOL
set_arc_token(auth_user())


# https://analysis-1.maps.arcgis.com/home/item.html?id=bca2c5de6b7448dc8c403eb793b37ec0
ev_srvr <- arc_open("bca2c5de6b7448dc8c403eb793b37ec0")
ev_srvr

# get just the layer
ev_layer <- get_layer(ev_srvr, 0)
ev_layer

# get all of the stations
all_stations <- arc_select(ev_layer, crs = 4326)

glimpse(all_stations)

# get an esri basemap to view with
basemap <- esri_style("streets", token = arc_token())

# preview all of the data
maplibre_view(all_stations, style = basemap)
