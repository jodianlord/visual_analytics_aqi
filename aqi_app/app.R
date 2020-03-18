library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(plotly)
library(knitr)
source("load_new_data.R")
source("maps.R")

cities = load_dataset()
maps = load_maps()
str(cities)

ui <- fluidPage(

    # Application title
    titlePanel("AQI Index"),
    
    # Show a plot of the generated distribution
    mainPanel(
        #DT::dataTableOutput("show_table"),
        plotlyOutput("mapplot")
        #DT::dataTableOutput("mapset")
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    map_visualise(input, output, cities)
    #show_table(input, output, cities)
    #show_mapset(input, output, maps)
}

# Run the application 
shinyApp(ui = ui, server = server)
