library(mapgl)
library(arcgis)

# authenticate to AGOL
set_arc_token(auth_user())

# Dashboard: https://analysis-1.maps.arcgis.com/home/item.html?id=be7379804b71468a85abe19697cf4ed5
# WebMap: https://analysis-1.maps.arcgis.com/home/item.html?id=e4af99086ccd42148f4352cc38378737
# FeatureServer: https://analysis-1.maps.arcgis.com/home/item.html?id=30e908e8415d4a03ab4cee6a9becd5e3
ev_srvr <- arc_open("30e908e8415d4a03ab4cee6a9becd5e3")
ev_srvr

# get just the layer
ev_layer <- get_layer(ev_srvr, 0)
ev_layer

# get all of the stations
all_stations <- arc_select(ev_layer, crs = 4326)

# preview
glimpse(all_stations)

# get an esri basemap to view with
basemap <- esri_style("streets", token = arc_token())

# preview all of the data
maplibre_view(all_stations, style = basemap)
