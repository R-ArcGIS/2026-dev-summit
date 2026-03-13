library(shiny)
library(calcite)
library(mapgl)
library(arcgisutils)
library(arcgislayers)

cities <- arc_read(
  "https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/USA_Major_Cities_/FeatureServer/0"
)

# create a basemap style
basemap <- esri_style("streets", token = auth_user())

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls"
  ),
  calcite_panel(
    heading = "USA Major Cities",
    style = "height: 100%",
    maplibreOutput("map", height = "100%")
  )
)

server <- function(input, output) {
  output$map <- renderMaplibre({
    maplibre(style = basemap, bounds = cities) |>
      add_circle_layer(
        id = "cities",
        source = cities,
        circle_color = "#0077cc",
        circle_radius = 4
      )
  })
}

shinyApp(ui, server)
