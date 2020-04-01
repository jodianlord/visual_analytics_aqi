# takes in the data, filters it by input and displays a map shaded with the data.

countries_scatterplot <- function(input, output, data){
  output$scatter <- renderPlot({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    
    ggplot(data, aes(x=Value, y=GDP_Per_Capita, text = paste("Country: ", Country))) +
      geom_point(size=5, col="red") +
      geom_vline(xintercept = 50) + geom_hline(yintercept = 35000) +
      xlab("Pollutant Level") + ylab("GDP Per Capita") +
      theme_light() +
      geom_text_repel(aes(label=Country)) +
      annotate("text", x = 25, y = 20000, alpha = 0.35, label = "Low GDP, Good Air Quality") +
      annotate("text", x = 25, y = 60000, alpha = 0.35, label = "High GDP, Good Air Quality") +
      annotate("text", x = 75, y = 20000, alpha = 0.35, label = "Low GDP, Bad Air Quality") +
      annotate("text", x = 75, y = 60000, alpha = 0.35, label = "High GDP, Bad Air Quality")
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
                         tm_style("gray") + tm_format("World"))
    m2 <- tmap_leaflet(tm_shape(data) + 
                         tm_polygons("GDP_Per_Capita", title="GDP Per Capita", palette="BuGn") +
                         tm_style("gray") + tm_format("World"))
    sync(m1, m2)
  })
}

line_country <- function(input, output, data){
  output$linecountry <- renderPlotly({
    country_tosubset = input$country_select
    data <- subset(data, Country == country_tosubset)
    pollutant_tosubset = input$pollutant
    data <- subset(data, Variable == pollutant_tosubset)
    scale <- mean(data$GDP_Per_Capita) / 10
    ggplot(data) +
      geom_line(aes(x=data$Year, y=data$GDP_Per_Capita, col="blue")) +
      geom_line(aes(x=data$Year, y=data$Value*scale, col="red")) +
      scale_y_continuous(sec.axis= sec_axis(~./scale, name="AQI"))
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

pollutant_visualise <- function(input, output, data){
  #Output a line plot of PM25 vs month
  output$singaporeplot <- renderPlotly({
    ggplot(data, aes(x=month)) +
      ggtitle("Average PM25 and PM10 levels over Months") +
      xlab("Date") + ylab("Pollutant Levels") + 
      scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
      theme(axis.text.x=element_text(angle=60, hjust=1)) +
      geom_line(aes(y=totalpm25), color="red") +
      geom_line(aes(y=totalpm10), color="blue")
  })
}

