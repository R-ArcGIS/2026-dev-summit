library(shiny)
library(calcite)
library(mapgl)
library(arcgisutils)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls"
  ),
  calcite_panel(
    heading = "Map",
    style = "height: 100%",
    maplibreOutput("map", height = "100%")
  )
)

server <- function(input, output) {
  output$map <- renderMaplibre({
    maplibre(style = esri_style("streets", token = auth_user()))
  })
}

shinyApp(ui, server)
