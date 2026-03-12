library(shiny)
library(calcite)

ui <- page_sidebar(
  sidebar = calcite_panel(
    heading = "Controls",
    calcite_block(
      heading = "Histogram",
      expanded = TRUE,
      calcite_slider(
        id = "bins",
        label_text = "Number of bins",
        min = 1,
        max = 50,
        value = 30
      )
    )
  ),
  calcite_panel(
    heading = "Old Faithful Eruptions",
    calcite_block(
      heading = "Histogram",
      expanded = TRUE,
      plotOutput("hist")
    ),
    calcite_block(
      heading = "input$bins",
      expanded = TRUE,
      verbatimTextOutput("bins_out")
    )
  )
)

server <- function(input, output) {
  output$bins_out <- renderPrint({
    input$bins
  })

  output$hist <- renderPlot({
    hist(
      faithful$waiting,
      breaks = input$bins$value,
      main = "Waiting time to next eruption",
      xlab = "Waiting time (minutes)"
    )
  })
}

shinyApp(ui, server)
