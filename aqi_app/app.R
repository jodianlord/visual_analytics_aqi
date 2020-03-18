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

ui <- fluidPage(

    # Application title
    titlePanel("AQI Index"),
    
    sidebarPanel(
        textInput("date_range", "Date", value="2000"),
        textInput("pollutant", "Pollutant", value="Mean population exposure to PM2.5")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Map", plotlyOutput("mapplot")),
                    tabPanel("Table", DT::dataTableOutput("show_table")))
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    map_visualise(input, output, cities)
    show_table(input, output, cities)
}

# Run the application 
shinyApp(ui = ui, server = server)
