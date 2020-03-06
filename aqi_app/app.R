#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("AQI Index"),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("singaporeplot")
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    cities = read.csv('all_cities.csv')
    singapore <- subset(cities, city='singapore')

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
    
    output$airquality <- renderPlot(({
        str(singapore)
        ggplot(singapore, aes(x=date, y=pm25)) +
            geom_point()
    }))
    
    output$singaporeplot <- renderPlot({
        plot(singapore$pm25, singapore$pm10)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
