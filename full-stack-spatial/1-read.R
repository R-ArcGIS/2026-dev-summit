library(arcgis)

# Search the Living Atlas
# https://livingatlas.arcgis.com/en/browse/

# Georgia redistricting blocks 2020
fid <- "c6b40311a51c49b1a201247e917a552d"

# or you can access the item by its url
# furl <- "https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/Georgia_Census_2020_Redistricting_Blocks/FeatureServer/0"

# create a reference to Item
blocks_ga <- arc_open(fid)
blocks_ga

# get Layer
blocks_lyr <- get_layer(blocks_ga, id = 0)

# Read in as an {sf} object
# blocks_sf <- arc_select(blocks_lyr)
# > dim(blocks_sf)
# [1] 232717    395

# select only the blocks in Fulton County
arc_select(
  blocks_lyr,
  where = "County_Name = 'Fulton County'"
)

# remove columns we don't want:
fulton_blocks <- arc_select(
  blocks_lyr,
  where = "County_Name = 'Fulton County'",
  fields = c("OBJECTID", "GEOID", "NAME", "County_Name", "POP100")
)

fulton_blocks
