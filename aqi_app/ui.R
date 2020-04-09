# Library imports
library('shiny') 
library('ggplot2') 
library('dplyr')
library('scales')
library('plotly')
library('knitr')
library('tmap')
library('WDI')
library('sf')
library('leaflet')
library('reshape2')
library('DT')
library('maps')
library('leaflet.minicharts')
library('manipulateWidget')
library('leafsync')
library('ggrepel')
library('purrr')
library('shinydashboard')
library('ggthemes')

data("World")
load_dataset <- function(){
  countries = read.csv('data/EXP_PM2_5_14032020074440630.csv', stringsAsFactors = FALSE)
  countries <- subset(countries, Macroregion == '-Total-')
  countries <- dplyr::select(countries, Country, Variable, Year, Unit, Value)
  countries <- mutate(countries, Country=recode(Country,
                                                'Korea' = 'South Korea',
                                                'Slovak Republic' = 'Slovakia',
                                                'United States' = 'United States of America',
                                                'Antigua and Barbuda' = 'Antigua',
                                                'Brunei Darussalam' = 'Brunei',
                                                'Cabo Verde' = 'Cape Verde',
                                                "China (People's Republic of)" = 'China',
                                                'Congo' = 'Democratic Republic of the Congo',
                                                "Democratic People's Republic of Korea" = 'North Korea',
                                                "Lao People's Democratic Republic" = 'Laos',
                                                'North Macedonia' = 'Macedonia',
                                                'Saint Vincent and the Grenadines' = 'Saint Vincent',
                                                'Eswatini' = 'Swaziland',
                                                'Syrian Arab Republic' = 'Syria',
                                                'Trinidad and Tobago' = 'Trinidad',
                                                'Viet Nam' = 'Vietnam'))
  
  exclusion_list <- anti_join(countries, World, by = c('Country' = 'sovereignt'))
  exclusion <- unique(as.vector(exclusion_list['Country']))
  
  countries <- subset(countries, !(Country %in% exclusion))
  
  world_geometry <- dplyr::select(World, sovereignt, geometry)
  
  countries <- right_join(world_geometry, countries, by=c('sovereignt' = 'Country'))
  
  colnames(countries)[1] <- "Country"
  
  #GDP per capita (constant 2000 US$)
  GDP_data = WDI(indicator='NY.GDP.PCAP.KD', start=1990, end=2020)
  GDP_data <- dplyr::select(GDP_data, country, year, NY.GDP.PCAP.KD)
  GDP_data <- mutate(GDP_data, country=recode(country,
                                              'United States' = 'United States of America',
                                              'Russian Federation' = 'Russia'))
  countries <- left_join(countries, GDP_data, by=c('Country' = 'country', 'Year' = 'year'))
  
  colnames(countries)[6] <- "GDP_Per_Capita"
  
  #countries <- anti_join(GDP_data, countries, by = c('country' = 'Country'))
  
  return(countries)
}

# Load datasets
countries = load_dataset()

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- sort(unique(countries$Country))

# Create UI
ui <- dashboardPage(skin="purple",
  # Application title
  dashboardHeader(title = span(tagList(icon("fas fa-fire"), "Purple Haze"))),
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
                                 selectInput("slope_select", "Top/Bottom N Countries: ", c("Top 5 Polluters", "Top 10 Polluters", "Top 20 Polluters",
                                                                                           "Bottom 5 Polluters", "Bottom 10 Polluters", "Bottom 20 Polluters")),
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
              fluidRow(plotOutput("slope", width = '40em', height = '60em'))
      ),
      tabItem(tabName="factorcomp",
              h1("AQI Factors over Time"),
              fluidRow(
                column(width = 5, height = 4, plotlyOutput("factorplot")),
                column(width = 5, height = 4, plotlyOutput("factorplot2"))
              )
      )
    )
  )
)