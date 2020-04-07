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

synced_maps <- function(input, output, data){
  output$syncedmaps <- renderUI({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    
    m1 <- tmap_leaflet(tm_shape(data) + 
                         tm_polygons("Value", title="Pollution", palette="YlOrRd") +
                         tm_style("gray") + tm_format("World") +
                         tm_view(set.zoom.limits = c(1, 3)))
    m2 <- tmap_leaflet(tm_shape(data) + 
                         tm_polygons("GDP_Per_Capita", title="GDP Per Capita", palette="BuGn") +
                         tm_style("gray") + tm_format("World") +
                         tm_view(set.zoom.limits = c(1, 3))) 
    sync(m1, m2) 
  })
}

countries_scatterplot <- function(input, output, data){
  output$scatter <- renderPlotly({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    
    data <- data %>% mutate(Pollutant.percentile = percent_rank(Value) * 100)
    data <- data %>% mutate(GDP_Per_Capita.percentile = percent_rank(GDP_Per_Capita) * 100)
    
    ggplot(data, aes(x=Pollutant.percentile, y=GDP_Per_Capita.percentile, text = paste("Country: ", Country))) +
      geom_point(size=2, col="blue") +
      geom_vline(xintercept = 50) + geom_hline(yintercept = 50) +
      xlab("Pollutant Level Percentile") + ylab("GDP Per Capita Percentile") +
      theme_light() +
      #geom_text_repel(aes(label=Country)) +
      annotate("text", x = 25, y = 25, alpha = 0.35, label = "Low GDP, Good Air Quality") +
      annotate("text", x = 25, y = 75, alpha = 0.35, label = "High GDP, Good Air Quality") +
      annotate("text", x = 75, y = 25, alpha = 0.35, label = "Low GDP, Bad Air Quality") +
      annotate("text", x = 75, y = 75, alpha = 0.35, label = "High GDP, Bad Air Quality")
  })
}

# displays a table filtered by input.
show_table <- function(input, output, data){
  output$show_table <- DT::renderDT({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    return(data)
  })
}

countries_lineplot <- function(input, output, data){
  output$compare <- renderPlot({
    pollutant_tosubset = input$pollutant_country
    data <- subset(data, Variable == pollutant_tosubset)
    
    first_country = input$first_country_select
    second_country = input$second_country_select
    data_first <- subset(data, Country == first_country)
    data_second <- subset(data, Country == second_country)
    
    ggplot() +
      geom_point(data_first, mapping = aes(x=GDP_Per_Capita, y=Value, text=paste("Year: ", Year)), color="black") +
      geom_line(data = data_first, aes(x=GDP_Per_Capita, y=Value), color = "red") +
      geom_point(data_second, mapping = aes(x=GDP_Per_Capita, y=Value, text=paste("Year: ", Year)), color="black") +
      geom_line(data = data_second, aes(x=GDP_Per_Capita, y=Value), color = "blue") +
      labs(x="GDP Per Capita", y="Pollutant Level", color="Legend") +
      geom_text_repel(data = rbind(data_first, data_second) %>% filter(Year == 2017), 
                      aes(label = Country, x=GDP_Per_Capita, y=Value) , 
                      hjust = "right", 
                      fontface = "bold", 
                      size = 5, 
                      nudge_x = .5, 
                      direction = "y") +
      geom_label(data = rbind(data_first, data_second), 
                 aes(label = Value, x=GDP_Per_Capita, y=Value), 
                 size = 4, 
                 label.padding = unit(0.05, "lines"), 
                 label.size = 0.0) +
      theme_light() 
  })
}


countries_slopegraph <- function(input, output, data){
  output$slope <- renderPlot({
    first_country = input$first_country_select
    second_country = input$second_country_select
    pollutant_tosubset = input$pollutant_country
    data <- subset(data, Variable == pollutant_tosubset)
    data <- subset(data, Year %in% c(1995, 2000, 2005, 2010, 2015))
    
    na_countries <- subset(data, is.na(data$Value))
    na_countries <- unique(na_countries$Country)
    
    data <- subset(data, !(Country %in% na_countries))
    data <- subset(data, Value != 0)
    
    
    tidy_data <- data[,c('Country', 'Value')]
    averages <- aggregate(tidy_data[,2], list(tidy_data$Country), mean)
    averages <- unique(averages)
    sorted_countries <- averages[order(averages$Value, decreasing=TRUE), ]
    sorted_countries_ascending <- averages[order(averages$Value, decreasing=FALSE), ]
    st_geometry(sorted_countries) <- NULL
    st_geometry(sorted_countries_ascending) <- NULL
    
    topn <- input$slope_select
    
    if(topn == "Top 10 Polluters"){
      top_n <- sorted_countries[1:10,1]
    }else if(topn == "Top 20 Polluters"){
      top_n <- sorted_countries[1:20,1]
    }else if(topn == "Bottom 10 Polluters"){
      top_n <- sorted_countries_ascending[1:10,1]
    }else{
      top_n <- sorted_countries_ascending[1:20,1]
    }
    
    data <- subset(data, Country %in% cbind(top_n, c(first_country, second_country)))
    ggplot(data, aes(x = Year, y = Value, group = Country)) +
      geom_line(aes(color = Country), size = 1) +
      labs(x="Year", y="Pollution Value") +
      geom_text_repel(data = data %>% filter(Year == 1995), 
                      aes(label = Country) , 
                      hjust = "left", 
                      fontface = "bold", 
                      size = 5, 
                      nudge_x = -.45, 
                      direction = "y") +
      geom_text_repel(data = data %>% filter(Year == 2015), 
                      aes(label = Country) , 
                      hjust = "right", 
                      fontface = "bold", 
                      size = 5, 
                      nudge_x = .5, 
                      direction = "y") +
      #theme_hc()+ scale_colour_hc() +
      theme(legend.position = "none")
    #      geom_label(aes(label = Value), 
    #                 size = 4, 
    #                 label.padding = unit(0.05, "lines"), 
    #                 label.size = 0.0)
  })
}

countries_factors <- function(input, output, data){
  output$factorplot <- renderPlotly(({
    factors = c("Mean population exposure to PM2.5", "Percentage of population exposed to more than 10 micrograms/m3", 
                "Percentage of population exposed to more than 15 micrograms/m3", "Percentage of population exposed to more than 25 micrograms/m3",
                "Percentage of population exposed to more than 35 micrograms/m3", "Percentage of population covered")
    factors_chosen = c("Mean population exposure to PM2.5", "Percentage of population exposed to more than 15 micrograms/m3")
    first_country = input$first_country_select_1
    second_country = input$second_country_select_1
    country_set = c(first_country, second_country)
    data_first <- subset(data, Country %in% country_set & Variable == "Mean population exposure to PM2.5")
    ggplot(data_first, aes(x=Year, y=Value, group=Country)) +
      geom_line(aes(color = Country), size = 1) +
      labs(title="Mean population exposure to PM2.5")
  }))
  
}

countries_factors_second <- function(input, output, data){
  output$factorplot2 <- renderPlotly(({
    factors = c("Mean population exposure to PM2.5", "Percentage of population exposed to more than 10 micrograms/m3", 
                "Percentage of population exposed to more than 15 micrograms/m3", "Percentage of population exposed to more than 25 micrograms/m3",
                "Percentage of population exposed to more than 35 micrograms/m3", "Percentage of population covered")
    factors_chosen = c("Mean population exposure to PM2.5", "Percentage of population exposed to more than 15 micrograms/m3")
    first_country = input$first_country_select_1
    second_country = input$second_country_select_1
    country_set = c(first_country, second_country)
    data_first <- subset(data, Country %in% country_set & Variable == "Percentage of population exposed to more than 15 micrograms/m3")
    ggplot(data_first, aes(x=Year, y=Value, group=Country)) +
      geom_line(aes(color = Country), size = 1) +
      labs(title="Percentage of population exposed to more than 15 micrograms/m3")
  }))
  
}

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  synced_maps(input, output, countries)
  countries_scatterplot(input, output, countries)
  countries_lineplot(input, output, countries)
  countries_slopegraph(input, output, countries)
  countries_factors(input, output, countries)
  countries_factors_second(input, output, countries)
}