library(arcgis)

set_arc_token(auth_user())

validate_gp_inputs <- function(input, token = arc_token()) {
  target_features <- list(
    value = list(
      url = "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1"
    )
  )
  input_feature <- list(value = as_featureset(input))

  arc_base_req(
    "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Upload/GPServer/Upload",
    path = "validate",
    query = c("f" = "json"),
    token = token
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
}

# small_pnts <- arc_read(
#   "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1"
# )
# input <- small_pnts[1:5, ]
# res <- validate_gp_inputs(input)

# res <-  validate_gp_inputs(all_points, token = NULL)
# res$validationResults$message[[1]]
