library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(plotly)
library(knitr)
library(tmap)
library(WDI)
library(sf)
library(leaflet)
source("load_data_sf.R")
source("maps.R")
source('viz2_pre_post.R')

# Load datasets
countries = load_dataset()
policies = load_policies()
#pollution = load_pollution()

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- unique(countries$Country)

# Map panel
map_panel <- tabPanel(
    'Map',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            selectInput("date_range", "Date:", year_list),
            selectInput("pollutant", "Pollutant: ", variable_list),
            selectInput("country_select", "Country: ", country_list)
        ),
        
        # Output: Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Table", DT::dataTableOutput("show_table")),
                        tabPanel("Tmap", leafletOutput("tmapplot")),
                        tabPanel("Country", plotlyOutput("linecountry")))
        ),
        
        # sidebar position
        position = 'right'
    )
)

# Policy effectivenes panel
# default_start_date <- as.Date('1990', '%Y')
# default_end_date <- as.Date('2020', '%Y')
policy_effectiveness_panel <- tabPanel(
    'Policy Effectiveness',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            #selectizeInput(
            #    'country',
            #    'Country',
            #    unique(subset(pollution, pollution$region %in% policies$country)$region)
            #),
            # dateRangeInput(
            #     'date_range',
            #     'Date Range',
            #     min = default_start_date,
            #     max = default_end_date,
            #     start = default_start_date,
            #     end = default_end_date,
            #     format = 'yyyy',
            #     startview = 'year'
            # ),
            checkboxGroupInput(
                'policies_selected',
                'Policies'
            )
        ),
        
        # Outputs
        mainPanel(
            plotlyOutput('prepostplot')
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
server <- function(input, output, session) {
    map_visualise(input, output, countries)
    map_tmap(input, output, countries)
    #prepost_visualise(input, output, pollution, policies)
    show_table(input, output, countries)
    line_country(input, output, countries)
    
    # Update input policies shown based on other inputs
    observe({
      policies_subset <- subset(policies, country == input$country)
      choices <- unique(policies_subset$policy_name)
      updateCheckboxGroupInput(
        session,
        'policies_selected',
        label = 'Policies',
        choices = choices,
        selected = choices
      )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
