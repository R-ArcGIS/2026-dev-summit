library(arcgis)

validate_gp_inputs <- function(input) {
  target_features <- list(
    value = list(
      # wa
      url = "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/SDE_ReportedSpillsToWater/FeatureServer/6"
      # mn
      # url = "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/9"
    )
  )
  input_feature <- list(value = as_featureset(input))

  res <- arc_base_req(
    # mn
    # "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Upload/GPServer/Upload",
    # wa
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Upload_Oil_Spill_Washington_State/GPServer/Upload%20Oil%20Spill%20Washington%20State",
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

  if (is.data.frame(res[[1]])) {
    res[[1]] <- data_frame(res[[1]])
  }

  if (is.data.frame(res[[2]])) {
    res[[2]] <- data_frame(res[[2]])
  }

  res
}

# small_pnts <- arc_read(
#   "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/9",
#   token = NULL
# )
# input <- small_pnts[1:5, ]
# res <- validate_gp_inputs(small_pnts, token = NULL)
# res <-  validate_gp_inputs(all_points, token = NULL)
# res$validationResults$message[[1]]
