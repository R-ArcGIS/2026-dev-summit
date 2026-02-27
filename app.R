library(sf)
library(mapgl)
library(shiny)
library(arcgis)
library(calcite)
library(shinyjs)
library(logger)

log_threshold(DEBUG)
source("validate-endpoint.R")
source("upload.R")


# sign into agol
set_arc_token(auth_user())

# furl <- "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/Hosted/env_small_spill_investigations/FeatureServer/1"
# points <- arc_read(furl)
# sf::st_write(points, "data/incidents.fgb")

points <- read_sf("data/incidents.fgb")

basemap <- esri_style("light-gray", token = arc_token())

ui <- page_actionbar(
  title = "Incident Upload",
  useShinyjs(),

  actions = calcite_action_bar(
    id = "action_bar",
    calcite_action_group(
      calcite_action(
        text = "Upload",
        icon = "upload-to",
        text_enabled = TRUE,
        active = TRUE
      ),
      calcite_action(
        text = "Analysis",
        icon = "analysis",
        text_enabled = TRUE
      )
    )
  ),

  panel_content = list(
    calcite_panel(
      id = "upload_panel",
      heading = "Upload Incident Features",

      calcite_block(
        heading = "Input Features",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_input_file(
          id = "csv_file",
          label_text = "Choose a CSV file",
          accept = "csv"
        )
      ),

      calcite_block(
        heading = "Geometry",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_notice(
          id = "col_map_placeholder",
          open = TRUE,
          kind = "info",
          width = "full",
          message = "Upload a CSV file to map columns."
        ),
        uiOutput("column_selects")
      ),

      calcite_block(
        id = "summary_block",
        heading = "Layer Summary",
        expanded = TRUE,
        collapsible = FALSE,
        uiOutput("layer_summary")
      ),

      footer = tagList(
        calcite_button(
          "Validate",
          id = "validate_btn",
          icon_start = "check-circle",
          width = "full",
          appearance = "outline",
          disabled = TRUE
        ),
        calcite_button(
          "Upload Features",
          id = "submit_btn",
          icon_start = "upload-to",
          width = "full",
          disabled = TRUE,
          appearance = "solid",
          kind = "brand"
        )
      )
    ),

    calcite_panel(
      id = "analysis_panel",
      heading = "Trace Downstream",
      hidden = TRUE,
      htmltools::div(
        id = "trace_scrim_wrapper",
        style = "display: none;",
        calcite_scrim(id = "trace_scrim", loading = TRUE)
      ),
      calcite_block(
        heading = "Select Area",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_notice(
          open = TRUE,
          kind = "info",
          width = "full",
          message = "Draw a polygon on the map to select incidents."
        )
      ),
      calcite_block(
        heading = "Selection Summary",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_tile(
          id = "selected_tile",
          icon = "map-pin",
          heading = "Selected incidents",
          description = "0",
          scale = "s"
        )
      ),
      footer = tagList(
        calcite_button(
          "Run Trace Downstream",
          id = "trace_btn",
          icon_start = "play",
          width = "full",
          appearance = "solid",
          kind = "brand"
        )
      )
    )
  ),

  uiOutput("validation_alert"),
  maplibreOutput("map", height = "100%")
)

server <- function(input, output, session) {
  validated_sf <- reactiveVal(NULL)

  output$map <- renderMaplibre({
    maplibre(
      basemap,
      bounds = points,
      attributionControl = FALSE
    ) |>
      add_circle_layer(
        id = "incidents",
        source = points,
        circle_color = "#f5a52385",
        circle_radius = 5,
        circle_opacity = 0.8
      ) |>
      add_draw_control(position = "top-right")
  })

  output$layer_summary <- renderUI({
    calcite_table(
      data = data.frame(
        ` ` = c("Features", "Fields"),
        `  ` = c("—", "—"),
        check.names = FALSE
      ),
      header = calcite_table_header(NULL),
      caption = "",
      bordered = TRUE,
      scale = "s"
    )
  })

  # panel switching
  panel_actions <- c("Upload", "Analysis")
  active_panel <- reactiveVal("Upload")

  observeEvent(
    input$action_bar,
    {
      clicked <- input$action_bar
      if (!clicked %in% panel_actions) {
        return()
      }
      active_panel(clicked)
      update_calcite("upload_panel", hidden = clicked != "Upload")
      update_calcite("analysis_panel", hidden = clicked != "Analysis")
    },
    ignoreInit = TRUE
  )

  # read CSV on upload, show column selects and summary
  uploaded_df <- reactive({
    req(input$csv_file)
    readr::read_csv(input$csv_file$datapath[1], show_col_types = FALSE)
  })

  observeEvent(input$csv_file, {
    df <- uploaded_df()
    cols <- names(df)[sapply(df, is.numeric)]
    n_features <- nrow(df)
    n_cols <- ncol(df)

    update_calcite("col_map_placeholder", open = FALSE)
    output$column_selects <- renderUI({
      tagList(
        calcite_label(
          "Select longitude column",
          calcite_select(
            id = "lon_col",
            label = "Longitude",
            values = cols,
            labels = cols
          )
        ),
        calcite_label(
          "Select latitude column",
          calcite_select(
            id = "lat_col",
            label = "Latitude",
            values = cols,
            labels = cols
          )
        )
      )
    })

    output$layer_summary <- renderUI({
      calcite_table(
        data = data.frame(
          property = c("Features", "Fields"),
          value = c(n_features, n_cols)
        ),
        header = calcite_table_header(NULL),
        caption = "",
        bordered = TRUE,
        scale = "s"
      )
    })

    update_calcite("validate_btn", disabled = FALSE)
  })

  # convert to sf and validate on button click
  observeEvent(input$validate_btn$clicks, {
    req(input$validate_btn$clicks > 0)
    req(uploaded_df(), input$lon_col, input$lat_col)

    lon <- input$lon_col$value
    lat <- input$lat_col$value

    sf_data <- rlang::try_fetch(
      sf::st_as_sf(uploaded_df(), coords = c(lon, lat), crs = 4326),
      error = function(cnd) {
        output$validation_alert <- renderUI({
          calcite_alert_danger(
            label = "Validation error",
            open = TRUE,
            auto_close = TRUE,
            auto_close_duration = "slow",
            title = "Error validating input",
            message = conditionMessage(cnd),
            placement = "bottom-end"
          )
        })
        NULL
      }
    )

    req(!is.null(sf_data))
    validated_sf(sf_data)

    maplibre_proxy("map") |>
      clear_layer("uploaded_points") |>
      add_circle_layer(
        id = "uploaded_points",
        source = sf_data,
        circle_color = "#0070ff",
        circle_radius = 5,
        circle_opacity = 0.8
      )

    res <- validate_gp_inputs(sf_data, token = NULL)
    msg <- res$validationResults$message[[1]]
    log_debug("validation message: {deparse(msg)}")

    if (!is.null(msg) && msg$type %in% c("warning", "error")) {
      output$validation_alert <- renderUI({
        calcite_alert_warning(
          label = "Validation warning",
          open = TRUE,
          title = "Too many features",
          message = msg$description,
          placement = "bottom-end"
        )
      })
      update_calcite("submit_btn", disabled = TRUE)
    } else {
      output$validation_alert <- renderUI({
        calcite_alert_success(
          label = "Validation passed",
          open = TRUE,
          title = "Validation passed",
          message = sprintf("%s features ready to upload.", nrow(sf_data)),
          placement = "bottom-end"
        )
      })
      update_calcite("submit_btn", disabled = FALSE)
    }
  })

  observeEvent(input$submit_btn$clicks, {
    # arc_gp_job() call goes here once service URL is available
  })

  filtered_points <- reactive({
    drawn <- get_drawn_features(maplibre_proxy("map"))
    req(!is.null(drawn), nrow(drawn) > 0)
    sf::st_transform(drawn, sf::st_crs(points)) |>
      (\(d) sf::st_filter(points, d))()
  })

  observe({
    n <- tryCatch(nrow(filtered_points()), error = function(e) 0)
    update_calcite("selected_tile", description = as.character(n))
    update_calcite("trace_btn", disabled = n < 1)
  })

  last_trace_click <- reactiveVal(0)

  observeEvent(input$trace_btn$clicks, {
    clicks <- input$trace_btn$clicks
    log_info("trace_btn clicks: {clicks}")
    req(clicks > 0)
    req(clicks != last_trace_click())
    last_trace_click(clicks)
    selected <- isolate(filtered_points())
    log_info("selected: {nrow(selected)} features")
    req(nrow(selected) > 0)

    trace_job <- arc_gp_job$new(
      base_url = "https://hydro.arcgis.com/arcgis/rest/services/Tools/Hydrology/GPServer/TraceDownstream",
      params = list(
        InputPoints = arcgisutils::as_esri_featureset(sf::st_geometry(
          selected
        )),
        Generalize = "true",
        f = "json"
      ),
      result_fn = arcgisutils::parse_gp_feature_record_set,
      token = arc_token()
    )

    shinyjs::show("trace_scrim_wrapper")
    update_calcite("trace_btn", disabled = TRUE)
    log_info("starting job")
    trace_job$start()
    log_debug("job started, awaiting...")
    result <- trace_job$await()
    log_info("job complete, hiding scrim")
    shinyjs::hide("trace_scrim_wrapper")
    log_info("scrim hidden")

    maplibre_proxy("map") |>
      clear_layer("trace_result") |>
      add_line_layer(
        id = "trace_result",
        source = result$geometry,
        line_color = "#0070ff",
        line_width = 3
      )
    log_info("layer added")
  })
}

shinyApp(ui, server)
