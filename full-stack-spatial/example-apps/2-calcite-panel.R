library(shiny)
library(calcite)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls"
  ),
  calcite_panel(
    heading = "Output"
  )
)

server <- function(input, output) {}

shinyApp(ui, server)
