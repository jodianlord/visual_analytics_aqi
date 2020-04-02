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