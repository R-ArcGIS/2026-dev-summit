library(shiny)
library(calcite)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Actions",
      expanded = TRUE,
      calcite_button(
        id = "btn",
        "Click me!",
        appearance = "solid",
        kind = "brand"
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
    input$btn
  })
}

shinyApp(ui, server)
