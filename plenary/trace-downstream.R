trace_downstream <- function(input, token = arc_token()) {
  arc_gp_job$new(
    base_url = "https://hydro.arcgis.com/arcgis/rest/services/Tools/Hydrology/GPServer/TraceDownstream",
    params = list(
      InputPoints = as_esri_featureset(st_cast(
        input,
        "POINT"
      )),
      Generalize = "true",
      f = "json"
    ),
    result_fn = parse_gp_feature_record_set,
    token = token
  )
}
