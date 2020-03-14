map_visualise <- function(input, output, data){
  #Output a line plot of PM25 vs month
  output$singaporeplot <- renderPlot({
    ggplot(data, aes(x=month)) +
      ggtitle("Average PM25 and PM10 levels over Months") +
      xlab("Date") + ylab("Pollutant Levels") + 
      scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
      theme(axis.text.x=element_text(angle=60, hjust=1)) +
      geom_line(aes(y=totalpm25), color="red") +
      geom_line(aes(y=totalpm10), color="blue")
  })
}