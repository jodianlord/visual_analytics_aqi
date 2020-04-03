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

source("load_data_sf.R")
source("maps.R")
source("country.R")

# Load datasets
countries = load_dataset()
pollution = load_pollution(countries)

year_list <- unique(countries$Year)
variable_list <- unique(countries$Variable)
country_list <- unique(countries$Country)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  synced_maps(input, output, countries)
  countries_scatterplot(input, output, countries)
  countries_lineplot(input, output, countries)
  countries_slopegraph(input, output, countries)
  countries_factors(input, output, countries)
  countries_factors_second(input, output, countries)
}