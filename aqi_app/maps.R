library(plotly)
library(rnaturalearth)
library(rnaturalearthdata)
library(knitr)

#world <- ne_countries(scale = "medium", returnclass = "sf")
map_visualise <- function(input, output, data){
  data <- subset(data, Year == "2000")
  data <- subset(data, Variable == "Mean population exposure to PM2.5")
  output$mapplot <- renderPlotly({
    ggplot(data, aes(x = long, y = lat, group = group )) +
      geom_polygon(aes(fill = Value))
  })
  
}

show_mapset <- function(input, output, data){
  #data <- unique(data[5])
  output$mapset <- DT::renderDT(data)
}

show_table <- function(input, output, data){
  output$show_table <- DT::renderDT(data)
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

