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
  'purrr',
  'shinydashboard',
  'ggthemes'
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
ui <- dashboardPage(
  # Application title
  dashboardHeader(title="AQI Index"),
  dashboardSidebar(
    sidebarMenu(id="mytabs",
                menuItem("World Overview", tabName = "world", icon = icon("fas fa-globe-americas")),
                menuItem("AQI vs GDP Comparison", tabName = "aqigdpcomp", icon = icon("th")),
                menuItem("Pollution Factors Comparison", tabName = "factorcomp", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName='world',
              h1("Input"),
              fluidRow(box(
                title="Controls",
                selectInput("date_range", "Date: ", year_list),
                selectInput("pollutant", "Pollutant: ", variable_list)
              )),
              h1("AQI vs GDP Per Capita Worldwide"),
              fluidRow(uiOutput("syncedmaps")),
              h1("GDP Per Capita vs Pollutant Levels Per Country"),
              fluidRow(plotlyOutput("scatter", width = '80em', height = '60em'))
      ),
      tabItem(tabName="aqigdpcomp",
              h1("Input"),
              fluidRow(box(
                title="Controls",
                selectInput("pollutant_country", "Pollutant: ", variable_list),
                selectInput("slope_select", "Top/Bottom N Countries: ", c("Top 10 Polluters", "Top 20 Polluters",
                                                                          "Bottom 10 Polluters", "Bottom 20 Polluters")),
                selectInput("first_country_select", "First Country: ", country_list),
                selectInput("second_country_select", "Second Country: ", country_list, selected = "Austria"))),
              h1("AQI vs GDP Comparison"),
              fluidRow(plotOutput("compare", width = '80em', height = '60em')),
              h1("AQI Comparison over Time"),
              fluidRow(plotOutput("slope", width = '80em', height = '60em'))
      ),
      tabItem(tabName="factorcomp",
              fluidRow(
                box(title = "Controls",
                    selectInput("first_country_select_1", "First Country: ", country_list),
                    selectInput("second_country_select_1", "Second Country: ", country_list, selected = "Austria")
                )
              ),
              h1("AQI Factors over Time"),
              fluidRow(
                column(width = 10, plotlyOutput("factorplot")),
                column(width = 10, plotlyOutput("factorplot2"))
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
