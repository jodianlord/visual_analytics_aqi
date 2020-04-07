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
  'purrr',
  'shinydashboard',
  'ggthemes'
)

for (p in packages) {
  #if(!require(p, character.only = T)) {
  #  install.packages(p)
  #}
  #library(p, character.only = T)
  library(p, character.only = T)
}

# Load datasets
countries = load_dataset()

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- sort(unique(countries$Country))

# Create UI
ui <- dashboardPage(skin="purple",
  # Application title
  dashboardHeader(title="AQI Index"),
  dashboardSidebar(
    sidebarMenu(id="mytabs",
                menuItem("World Overview", tabName = "world", icon = icon("fas fa-globe-americas")),
                menuItem("AQI vs GDP Comparison", tabName = "aqigdpcomp", icon = icon("fas fa-cloud")),
                menuItem("Pollution Factors Comparison", tabName = "factorcomp", icon = icon("fas fa-industry")),
                conditionalPanel(condition="input.mytabs == 'world'",
                                 selectInput("date_range", "Date: ", year_list),
                                 selectInput("pollutant", "Pollutant: ", variable_list)),
                conditionalPanel(condition="input.mytabs == 'aqigdpcomp'",
                                 selectInput("pollutant_country", "Pollutant: ", variable_list),
                                 selectInput("slope_select", "Top/Bottom N Countries: ", c("Top 10 Polluters", "Top 20 Polluters",
                                                                                           "Bottom 10 Polluters", "Bottom 20 Polluters")),
                                 selectInput("first_country_select", "First Country: ", country_list, selected = "Australia"),
                                 selectInput("second_country_select", "Second Country: ", country_list, selected = "Austria")
                ),
                conditionalPanel(condition="input.mytabs == 'factorcomp'", 
                                 selectInput("first_country_select_1", "First Country: ", country_list, selected = "Australia"),
                                 selectInput("second_country_select_1", "Second Country: ", country_list, selected = "Austria")
                )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName='world',
              h1("AQI vs GDP Per Capita Worldwide"),
              fluidRow(uiOutput("syncedmaps")),
              h1("GDP Per Capita vs Pollutant Levels Per Country"),
              fluidRow(plotlyOutput("scatter", width = '40em', height = '30em'))
      ),
      tabItem(tabName="aqigdpcomp",
              h1("AQI vs GDP Comparison"),
              fluidRow(plotOutput("compare", width = '40em', height = '30em')),
              h1("AQI Comparison over Time"),
              fluidRow(plotOutput("slope", width = '40em', height = '30em'))
      ),
      tabItem(tabName="factorcomp",
              h1("AQI Factors over Time"),
              fluidRow(
                column(width = 10, plotlyOutput("factorplot")),
                column(width = 10, plotlyOutput("factorplot2"))
              )
      )
    )
  )
)