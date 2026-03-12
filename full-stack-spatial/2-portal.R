library(dplyr)
library(arcgis)

token <- auth_user()
set_arc_token(token)

self <- arc_user_self()

# see summary of user
str(self, 1)

# user's groups
self_groups <- self$groups |>
  select(title, snippet, id)

# get shared update group id
group_id <- self_groups |>
  filter(title == "R Testing (Shared Update)") |>
  pull(id)

group_id

# all group users
arc_group_users(group_id)

# list all items in the group
all_items <- arc_group_content(group_id) |>
  select(id, type, title, name, snippet)

all_items

# filter to csv files
all_items |>
  filter(type == "CSV")

# get the ID for atlanta_businesses
atl_csv_id <- all_items |>
  filter(title == "atlanta_businesses") |>
  pull(id)

# create a portal item
atl_item <- arc_open(atl_csv_id)
atl_item

# create a temp file to write the csv to
tmp <- tempfile(fileext = ".csv")

# we can now download the raw data of the portal item
atl_csv_raw <- arc_item_data(atl_item)

# write it to the temp file
writeBin(atl_csv_raw, tmp)

# read the csv
to_geocode <- readr::read_csv(tmp)

# next we need to geocode the addresses!
