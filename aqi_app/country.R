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