library(shiny)
library(calcite)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Settings",
      expanded = TRUE
    )
  ),
  calcite_panel(
    heading = "Output",
    calcite_block(
      heading = "Results",
      expanded = TRUE
    )
  )
)

server <- function(input, output) {}

shinyApp(ui, server)
