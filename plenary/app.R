library(shiny)
library(arcgis)
library(calcite) # 👈🏼 new!

# sign into AGOL
set_arc_token(auth_user())

ui <- page_actionbar(
  title = "Incident Upload",
  shinyjs::useShinyjs(),

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
    ),
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
        shinyjs::hidden(calcite_button(
          "Upload Features",
          id = "submit_btn",
          icon_start = "upload-to",
          width = "full",
          appearance = "solid",
          kind = "brand"
        ))
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
          message = "Draw a rectangle on the map to select incidents."
        ),
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
  tags$style(".maplibregl-ctrl-top-right { display: none !important; }"),
  tags$script(htmltools::HTML(
    "
    Shiny.addCustomMessageHandler('draw_rectangle', function(msg) {
      document.querySelector('.mapbox-gl-draw_rectangle').click();
    });
    Shiny.addCustomMessageHandler('draw_trash', function(msg) {
      document.querySelector('.mapbox-gl-draw_trash').click();
    });
  "
  )),

  uiOutput("validation_alert"),
  htmltools::div(
    style = "position: relative; height: 100%;",
    mapgl::maplibreOutput("map", height = "100%"),
    htmltools::div(
      style = "position: absolute; top: 10px; right: 10px; z-index: 10;",
      calcite_action_bar(
        id = "map_action_bar",
        expand_disabled = TRUE,
        scale = "s",
        calcite_action_group(
          scale = "s",
          calcite_action(
            id = "draw_rect_action",
            text = "Select Area",
            icon = "rectangle-plus",
            scale = "s"
          ),
          calcite_action(
            id = "trash_action",
            text = "Delete",
            icon = "trash",
            scale = "s"
          )
        )
      )
    ),
    htmltools::div(
      id = "map_scrim_wrapper",
      style = "display: none; position: absolute; inset: 0;",
      calcite_scrim(id = "map_scrim", loading = TRUE)
    )
  )
)

placeholder_summary <- function() {
  calcite_table(
    data = data.frame(property = c("Features", "Fields"), value = c("—", "—")),
    header = calcite_table_header(NULL),
    caption = "",
    bordered = TRUE,
    scale = "s"
  )
}

source("upload.R")
source("validate-endpoint.R")

incident_circle_color <- "#FFAA00"
incident_color_border <- "#A87000"

# washington incidents
furl <- "https://dev2026gpservice.westus.cloudapp.azure.com/server/rest/services/ContaminationSites/FeatureServer/0"

server <- function(input, output, session) {
  validated_sf <- reactiveVal(NULL)
  points_rv <- reactiveVal(arc_read(furl, token = NULL))

  output$map <- mapgl::renderMaplibre({
    mapgl::maplibre(
      mapgl::esri_style("oceans", token = arc_token()),
      center = c(-85.8804793, 43.7213087),
      zoom = 10,
      attributionControl = FALSE
    ) |>
      mapgl::add_circle_layer(
        id = "incidents",
        source = points_rv(),
        circle_color = incident_circle_color,
        circle_stroke_color = incident_color_border,
        circle_stroke_width = 0.2,
        circle_radius = 5,
        circle_opacity = 0.8
      ) |>
      mapgl::add_draw_control(
        position = "top-right",
        rectangle = TRUE,
        controls = list(
          point = FALSE,
          line_string = FALSE,
          polygon = FALSE,
          trash = TRUE,
          combine_features = FALSE,
          uncombine_features = FALSE
        )
      )
  })

  output$layer_summary <- renderUI({
    placeholder_summary()
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
            labels = cols,
            value = if ("X" %in% cols) "X" else NULL
          )
        ),
        calcite_label(
          "Select latitude column",
          calcite_select(
            id = "lat_col",
            label = "Latitude",
            values = cols,
            labels = cols,
            value = if ("Y" %in% cols) "Y" else NULL
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

    shinyjs::show("validate_btn")
    update_calcite("validate_btn", disabled = FALSE)
    shinyjs::hide("submit_btn")
    validated_sf(NULL)
  })

  last_validate_click <- reactiveVal(0)

  # convert to sf and validate on button click
  observeEvent(input$validate_btn$clicks, {
    clicks <- input$validate_btn$clicks
    req(clicks > 0)
    req(clicks != last_validate_click())
    last_validate_click(clicks)
    req(uploaded_df(), input$lon_col, input$lat_col)

    lon <- input$lon_col$value
    lat <- input$lat_col$value

    sf_data <- rlang::try_fetch(
      sf::st_as_sf(uploaded_df(), coords = c(lon, lat), crs = 6497),
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

    mapgl::maplibre_proxy("map") |>
      mapgl::clear_layer("uploaded_points") |>
      mapgl::add_circle_layer(
        id = "uploaded_points",
        source = sf_data,
        circle_color = "#A900E6",
        circle_radius = 7,
        circle_stroke_color = "#4C0073",
        circle_stroke_width = 0.5,
        circle_opacity = 0.8
      )

    res <- validate_gp_inputs(sf_data)
    msg <- res$validationResults$message[[1]]
    logger::log_debug("validation message: {deparse(msg)}")

    if (!is.null(msg) && msg$type %in% c("warning", "error")) {
      output$validation_alert <- renderUI({
        calcite_alert_warning(
          label = "Validation warning",
          open = TRUE,
          title = "Validation error",
          message = msg$description,
          placement = "bottom-end"
        )
      })
      # keep validate visible, hide submit
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
      shinyjs::hide("validate_btn")
      shinyjs::show("submit_btn")
    }
  })

  last_submit_click <- reactiveVal(0)

  observeEvent(input$submit_btn$clicks, {
    clicks <- input$submit_btn$clicks
    req(clicks > 0)
    req(clicks != last_submit_click())
    last_submit_click(clicks)
    sf <- validated_sf()
    req(!is.null(sf))

    shinyjs::show("map_scrim_wrapper")
    logger::log_info("starting upload job")
    status <- upload_features(sf, target, token = NULL)
    logger::log_info("upload status: {status}")

    if (status == "esriJobSucceeded") {
      output$validation_alert <- renderUI({
        calcite_alert_success(
          label = "Upload success",
          open = TRUE,
          title = "Upload succeeded",
          message = "Features successfully uploaded.",
          placement = "bottom-end"
        )
      })

      logger::log_info("reloading points from service")
      points_rv(arc_read(furl, token = NULL))
      logger::log_info("points reloaded: {nrow(points_rv())} features")
      logger::log_info("clearing layers and re-adding incidents")
      mapgl::maplibre_proxy("map") |>
        mapgl::clear_layer("uploaded_points") |>
        mapgl::clear_layer("incidents") |>
        mapgl::add_circle_layer(
          id = "incidents",
          source = points_rv(),
          circle_color = "#e91e8cc0",
          circle_radius = 5,
          circle_opacity = 0.8
        )
      logger::log_info("layers updated")
      shinyjs::hide("map_scrim_wrapper")

      validated_sf(NULL)
      shinyjs::show("validate_btn")
      update_calcite("validate_btn", disabled = TRUE)
      shinyjs::hide("submit_btn")
      update_calcite("col_map_placeholder", open = TRUE)
      output$column_selects <- renderUI({
        NULL
      })
      output$layer_summary <- renderUI({
        placeholder_summary()
      })
    } else {
      output$validation_alert <- renderUI({
        calcite_alert_danger(
          label = "Upload error",
          open = TRUE,
          title = "Upload failed",
          message = sprintf("Job status: %s", status),
          placement = "bottom-end"
        )
      })
    }
  })

  observeEvent(input$draw_rect_action$clicked, {
    session$sendCustomMessage("draw_rectangle", list())
  })

  observeEvent(input$trash_action$clicked, {
    session$sendCustomMessage("draw_trash", list())
  })

  filtered_points <- reactive({
    drawn <- mapgl::get_drawn_features(mapgl::maplibre_proxy("map"))
    req(!is.null(drawn), nrow(drawn) > 0)
    sf::st_transform(drawn, sf::st_crs(points_rv())) |>
      (\(d) sf::st_filter(points_rv(), d))()
  })

  observe({
    n <- tryCatch(nrow(filtered_points()), error = function(e) 0)
    update_calcite("selected_tile", description = as.character(n))
    update_calcite("trace_btn", disabled = n < 1)
  })

  last_trace_click <- reactiveVal(0)

  observeEvent(input$trace_btn$clicks, {
    clicks <- input$trace_btn$clicks
    logger::log_info("trace_btn clicks: {clicks}")
    req(clicks > 0)
    req(clicks != last_trace_click())
    last_trace_click(clicks)
    selected <- isolate(filtered_points())
    logger::log_info("selected: {nrow(selected)} features")
    req(nrow(selected) > 0)

    selected_4326 <- sf::st_transform(selected, 4326)
    # browser()
    logger::log_info(
      "selected coords: {paste(sf::st_coordinates(selected_4326), collapse = ', ')}"
    )

    trace_job <- arc_gp_job$new(
      base_url = "https://hydro.arcgis.com/arcgis/rest/services/Tools/Hydrology/GPServer/TraceDownstream",
      params = list(
        InputPoints = arcgisutils::as_esri_featureset(sf::st_cast(
          selected_4326,
          "POINT"
        )),
        Generalize = "true",
        f = "json"
      ),
      result_fn = arcgisutils::parse_gp_feature_record_set,
      token = arc_token()
    )

    shinyjs::show("trace_scrim_wrapper")
    update_calcite("trace_btn", disabled = TRUE)
    logger::log_info("starting job")
    trace_job$start()
    logger::log_debug("job started, awaiting...")
    result <- trace_job$await()
    logger::log_info("job complete, hiding scrim")
    shinyjs::hide("trace_scrim_wrapper")
    logger::log_info("scrim hidden")

    mapgl::maplibre_proxy("map") |>
      mapgl::clear_layer("trace_result") |>
      mapgl::add_line_layer(
        id = "trace_result",
        source = result$geometry,
        line_color = "#0070ff",
        line_width = 3
      )
    logger::log_info("layer added")
  })
}

shinyApp(ui, server)
