# takes in the data, filters it by input and displays a map shaded with the data.
map_visualise <- function(input, output, data){
  # CONSIDER USING TMAP
  output$mapplot <- renderPlotly({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    
    ggplot(data, aes(x = long, y = lat, group = group )) +
      geom_polygon(aes(fill = Value))
  })
}

map_tmap <- function(input, output, data){
  output$tmapplot <- renderLeaflet({
    year_tosubset = input$date_range
    pollutant_tosubset = input$pollutant
    data <- subset(data, Year == year_tosubset)
    data <- subset(data, Variable == pollutant_tosubset)
    
    map <- tm_shape(data) + 
      tm_polygons("GDP_Per_Capita", title="GDP Per Capita") +
      tm_shape(data) +
      tm_bubbles(size="Value", id="pollutant", col="blue") +
      tm_style_gray() + tm_format_World_wide()
    tmap_leaflet(map)
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

