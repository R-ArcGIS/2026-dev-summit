library(shiny)
library(calcite)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Variable",
      expanded = TRUE,
      calcite_select(
        id = "pick",
        label = "Pick a variable",
        values = c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"),
        labels = c("Bill Length", "Bill Depth", "Flipper Length", "Body Mass")
      )
    )
  ),
  calcite_panel(
    heading = "Output",
    calcite_block(
      heading = "Results",
      expanded = TRUE,
      verbatimTextOutput("out")
    )
  )
)

server <- function(input, output) {
  output$out <- renderPrint({
    input$pick
  })
}

shinyApp(ui, server)
