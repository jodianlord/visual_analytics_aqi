library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
source("load_data.R")
source("maps.R")

cities = load_dataset('all_cities.csv')
singapore <- subset(cities, city='singapore')

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
    map_visualise(input, output, singapore)
}

# Run the application 
shinyApp(ui = ui, server = server)
