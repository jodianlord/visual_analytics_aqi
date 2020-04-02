# Library imports
packages = c(
  'shiny', 
  'ggplot2', 
  'dplyr',
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
  'ggrepel',
  'CGPfunctions',
  'purrr'
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
          plotlyOutput("scatter", width = '80em', height = '60em')
        )
      )
    ),
    tabPanel('Country Comparison',
      sidebarLayout(
        sidebarPanel(
          selectInput("pollutant_country", "Pollutant: ", variable_list),
          selectInput("first_country_select", "First Country: ", country_list),
          selectInput("second_country_select", "Second Country: ", country_list, selected = "Austria")
        ),
        mainPanel(
          h1("AQI vs GDP Comparison"),
          plotOutput("compare"),
          h1("AQI Comparison over Time"),
          plotOutput("slope"),
          h1("AQI Factors over Time"),
          fluidRow(
            column(width = 10, plotlyOutput("factorplot")),
            column(width = 10, plotlyOutput("factorplot2"))
          )
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
  countries_slopegraph(input, output, countries)
  countries_factors(input, output, countries)
  countries_factors_second(input, output, countries)
}

# Run the application 
shinyApp(ui = ui, server = server)
