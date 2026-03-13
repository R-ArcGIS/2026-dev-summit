library(shiny)
library(calcite)
library(mapgl)
library(arcgisutils)
library(arcgislayers)
library(dplyr)

cities <- arc_read(
  "https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/USA_Major_Cities_/FeatureServer/0"
)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Population",
      expanded = TRUE,
      calcite_slider(
        id = "min_pop",
        label_text = "Minimum population",
        min = 0,
        max = 500000,
        value = 0,
        step = 10000
      )
    )
  ),
  calcite_panel(
    heading = "USA Major Cities",
    style = "height: 100%",
    maplibreOutput("map", height = "100%")
  )
)

server <- function(input, output) {
  output$map <- renderMaplibre({
    maplibre(
      style = esri_style("streets", token = auth_user()),
      bounds = cities
    ) |>
      add_circle_layer(
        id = "cities",
        source = cities,
        circle_color = "#0077cc",
        circle_radius = 4
      )
  })

  observeEvent(input$min_pop, {
    maplibre_proxy("map") |>
      set_filter(
        "cities",
        list(
          ">=",
          get_column("POPULATION"),
          input$min_pop$value
        )
      )
  })
}

shinyApp(ui, server)
