# Import packages
library(ggplot2)

# Visualise Prepost graph
prepost_visualise <- function(input, output, cities, policies) {
  print(input)
  output$prepostplot = renderPlotly({
    ggplot(cities, aes(x <- long, y <- lat, group <- group )) +
      geom_polygon(aes(fill <- Value))
  })
}