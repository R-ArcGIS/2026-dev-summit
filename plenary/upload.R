target <- arc_open(
  "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/ContaminationSites/FeatureServer/0",
  token = NULL
)

upload_features <- function(input, target, token = NULL) {
  input <- sf::st_transform(input, 6497)
  job <- arc_gp_job$new(
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Validate_and_Upload_Incident_Data/GPServer/Validate%20and%20Upload%20Incident%20Data",
    params = list(
      in_features = as_gp_feature_record_set(input),
      target_features = as_gp_feature_record_set(target),
      f = "json"
    ),
    token = token
  )
  job$start()
  logger::log_info(paste(capture.output(print(job)), collapse = "\n"))
  job$await()
  logger::log_info(paste(capture.output(print(job)), collapse = "\n"))
  job$status@status
}

# usage
# upload_features(input, target, NULL)
