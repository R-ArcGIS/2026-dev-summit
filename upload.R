target <- arc_open(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/9",
  token = NULL
)

upload_features <- function(input, target, token = NULL) {
  job <- arc_gp_job$new(
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Upload/GPServer/Upload",
    params = list(
      in_features = as_gp_feature_record_set(input),
      target_features = as_gp_feature_record_set(target),
      f = "json"
    ),
    token = token
  )
  job$start()
  job$await()
  job$status@status
}

# usage
# upload_features(input, target, NULL)
