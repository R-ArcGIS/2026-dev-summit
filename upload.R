target_feats <- arc_open(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1",
  token = NULL
)

upload_features <- function(input, target, token = NULL) {
  job <- arc_gp_job$new(
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Upload/GPServer/Upload",
    params = list(
      in_features = as_gp_feature_record_set(input),
      target_features = as_gp_feature_record_set(target_feats),
      f = "json"
    ),
    token = token
  )
  job$start()
  job$status
  job$results()
}

job$status
job$results

resp <- arc_base_req(
  job$base_url,
  token = NULL,
  path = c("jobs", job$id, "results"),
  query = c(f = "json")
) |>
  httr2::req_error(is_error = function(e) FALSE) |>
  httr2::req_perform() |>
  httr2::resp_body_string()
resp
