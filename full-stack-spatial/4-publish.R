# create a unique name for the new layer to publish
layer_name <- sprintf("atl-businesses-%s", ulid::ulid())

# create a new feature service
publish_res <- publish_layer(to_upload, layer_name)

# give a moment to update and publish
new_fsrvr <- publish_res$services$encodedServiceURL
new_fsrvr

# connect to the feature server
atl_fsrvr <- arc_open(new_fsrvr)

# get the feature layer
# read new feature server
get_layer(atl_fsrvr, 0) |>
  arc_select()
