library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(plotly)
library(knitr)
source("load_new_data.R")
source("maps.R")
source('viz2_pre_post.R')

# Load datasets
cities = load_dataset()
maps = load_maps()
str(cities)

# Map panel
map_panel <- tabPanel(
    'Map',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            'TODO'
        ),
        
        # Outputs
        mainPanel(
            DT::dataTableOutput("show_table"),
            plotlyOutput("mapplot")
            #DT::dataTableOutput("mapset")
        ),
        
        # sidebar position
        position = 'right'
    )
)
  

# Policy effectivenes panel
policy_effectiveness_panel <- tabPanel(
    'Policy Effectiveness',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            'TODO'
        ),
        
        # Outputs
        mainPanel(
            'TODO'
        ),
        
        # sidebar position
        position = 'right'
    )
)

# GDP vs AQI panel
gdp_aqi_panel <- tabPanel(
    'GDP vs AQI',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            'TODO'
        ),
        
        # Outputs
        mainPanel(
            'TODO'
        ),
        
        # sidebar position
        position = 'right'
    )
)

# Create UI
ui <- navbarPage(
    # Application title
    titlePanel("AQI Index"),
    
    # Panels
    map_panel,
    policy_effectiveness_panel,
    gdp_aqi_panel
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    map_visualise(input, output, cities)
    prepost_visualise(input, output, cities, FALSE)
    show_table(input, output, cities)
    #show_mapset(input, output, maps)
}

# Run the application 
shinyApp(ui = ui, server = server)
