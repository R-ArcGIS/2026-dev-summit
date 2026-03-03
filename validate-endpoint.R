library(arcgis)

validate_gp_inputs <- function(input) {
  target_features <- list(
    value = list(
      url = "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/ContaminationSites/FeatureServer/0"
    )
  )

  fset <- as_featureset(input)
  fset$spatialReference$wkid <- as.integer(fset$spatialReference$wkid)
  input_feature <- list(value = fset)

  res <- arc_base_req(
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Validate_and_Upload_Incident_Data/GPServer/Validate%20and%20Upload%20Incident%20Data",
    path = "validate",
    query = c("f" = "json")
  ) |>
    httr2::req_body_form(
      in_features = yyjsonr::write_json_str(
        input_feature,
        auto_unbox = TRUE
      ),
      target_features = yyjsonr::write_json_str(
        target_features,
        auto_unbox = TRUE
      )
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_string() |>
    yyjsonr::read_json_str()

  res
}
