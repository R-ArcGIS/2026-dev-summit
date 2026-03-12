library(shiny)
library(calcite)

# focus: now we connect the slider to the server via input$my_slider

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Settings",
      expanded = TRUE,
      calcite_slider(
        id = "my_slider",
        label_text = "Choose a value",
        min = 0,
        max = 100,
        value = 50
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
    input$my_slider
  })
}

shinyApp(ui, server)
