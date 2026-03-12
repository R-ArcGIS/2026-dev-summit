library(shiny)
library(calcite)

ui <- page_sidebar()

server <- function(input, output) {
  # input = messages from the browser
  # output = what you send back to the browser
}

shinyApp(ui, server)
