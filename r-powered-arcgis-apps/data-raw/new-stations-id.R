readr::read_csv("New_Stations.csv") |>
  mutate(id = ulid::ulid(n())) |>
  rename_with(heck::to_snek_case) |>
  readr::write_csv("data/new-stations.csv")
