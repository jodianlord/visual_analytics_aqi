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
  'leafsync',
  'ggrepel'
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
source("country.R")


# Load datasets
countries = load_dataset()
pollution = load_pollution(countries)

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- unique(countries$Country)

# Create UI
ui <- fluidPage(
  # Application title
  titlePanel("AQI Index"),
  tabsetPanel(
    tabPanel('World Overview',
      sidebarLayout(
        # Inputs
        sidebarPanel(
          selectInput("date_range", "Date:", year_list),
          selectInput("pollutant", "Pollutant: ", variable_list)
        ),
        # Output: Show a plot of the generated distribution
        mainPanel(
          h1("AQI vs GDP Per Capita Worldwide"),
          fluidRow(uiOutput("syncedmaps")),
          h1("GDP Per Capita vs Pollutant Levels Per Country"),
          plotOutput("scatter")
        )
      )
    ),
    tabPanel('Country Specific',
      sidebarLayout(
        sidebarPanel(
          selectInput("date_range", "Date:", year_list),
          selectInput("pollutant", "Pollutant: ", variable_list),
          selectInput("first_country_select", "First Country: ", country_list),
          selectInput("second_country_select", "Second Country: ", country_list, selected = "Austria")
        ),
        mainPanel(
          h1("AQI vs GDP Comparison"),
          plotlyOutput("compare")
        )
      )         
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  synced_maps(input, output, countries)
  countries_scatterplot(input, output, countries)
  countries_lineplot(input, output, countries)
}

# Run the application 
shinyApp(ui = ui, server = server)
