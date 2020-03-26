# Library imports
packages = c(
  'shiny', 
  'ggplot2', 
  'dplyr',
  'lubridate',
  'scales',
  'plotly',
  'knitr',
  'tmap',
  'WDI',
  'sf',
  'leaflet',
  'reshape2'
)
for (p in packages) {
  if(!require(p, character.only = T)) {
    install.packages(p)
  }
  library(p, character.only = T)
}

# Local imports
source("load_data_sf.R")
source("maps.R")
source('viz2_pre_post.R')
source("boxplot.R")


# Load datasets
countries = load_dataset()
pollution = load_pollution(countries)
policies = load_policies()

str(policies)

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- unique(subset(pollution, pollution$country %in% policies$country)$country)

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
default_start_date <- as.Date('1990', '%Y')
default_end_date <- as.Date('2020', '%Y')
policy_effectiveness_panel <- tabPanel(
    'Policy Effectiveness',
    sidebarLayout(
        # Inputs
        sidebarPanel(
            selectizeInput(
                'country',
                'Country',
                country_list
            ),
             dateRangeInput(
                 'date_range',
                 'Date Range',
                 min = default_start_date,
                 max = default_end_date,
                 start = default_start_date,
                 end = default_end_date,
                 format = 'yyyy',
                 startview = 'year'
             ),
            checkboxGroupInput(
                'policies_selected',
                'Policies',
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
            tabsetPanel(type = "tabs",
                        tabPanel("Boxplot", plotOutput("gdpaqi_boxplot")),
                        tabPanel("WIP", "TODO"))
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
    prepost_visualise(input, output, pollution, policies)
    show_table(input, output, countries)
    line_country(input, output, countries)
    generate_boxplot(input, output, countries)
    
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
