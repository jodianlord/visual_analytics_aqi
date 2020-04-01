countries_lineplot <- function(input, output, data){
  output$compare <- renderPlotly({
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
    data <- subset(data, Country %in% c("Singapore", "Malaysia", "Russia", first_country, second_country))
    ggplot(data, aes(x = Year, y = Value, group = Country)) +
      geom_line(aes(color = Country), size = 1) +
      geom_text_repel(data = data %>% filter(Year == 1995), 
                      aes(label = Country) , 
                      hjust = "left", 
                      fontface = "bold", 
                      size = 3, 
                      nudge_x = -.45, 
                      direction = "y") +
      geom_text_repel(data = data %>% filter(Year == 2015), 
                      aes(label = Country) , 
                      hjust = "right", 
                      fontface = "bold", 
                      size = 3, 
                      nudge_x = .5, 
                      direction = "y") +
      geom_label(aes(label = Value), 
                 size = 2.5, 
                 label.padding = unit(0.05, "lines"), 
                 label.size = 0.0)
  })
}