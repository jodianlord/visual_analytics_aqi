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
  'reshape2',
  'DT',
  'maps',
  'leaflet.minicharts',
  'manipulateWidget',
  'leafsync'
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


# Load datasets
countries = load_dataset()
pollution = load_pollution(countries)

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
          uiOutput("syncedmaps")
          #DT::dataTableOutput("show_table"),
          #combineWidgets(leafletOutput("tmapplot"), leafletOutput("pollutionplot"), ncol=2),
          #leafletOutput("tmapplot"),
          #leafletOutput("pollutionplot"),
          #plotlyOutput("linecountry"),
          #plotlyOutput("scatter")
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
    map_panel
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    map_visualise(input, output, countries)
    map_tmap(input, output, countries)
    map_tmap_pollution(input, output, countries)
    show_table(input, output, countries)
    line_country(input, output, countries)
    countries_scatterplot(input, output, countries)
    synced_maps(input, output, countries)
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
