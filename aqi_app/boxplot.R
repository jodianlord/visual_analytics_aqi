generate_boxplot <- function(input, output, data){
  # set seed for random number generation to allow you to replicate my data
  set.seed(1)
  
  # set the standard deviation for the data
  sd = 3
  
  # generate fictitious pollution data for New York and London
  co2.ny = rnorm(120, 7, sd)
  co2.london = rnorm(120, 9, sd)
  co2.la = rnorm(120, 10.5, sd)
  ch4.ny = c(rnorm(100, 12, sd), rep(NA, 20))
  ch4.london = c(rnorm(100, 15, sd), rep(NA, 20))
  ch4.la = c(rnorm(100, 18, sd), rep(NA, 20))
  
  # set vectors for labelling the data with location and pollutant
  location = c('New York', 'London', 'Los Angeles', 'New York', 'London', 'Los Angeles')
  pollutant = c('CO2', 'CO2', 'CO2', 'CH4', 'CH4', 'CH4')
  
  # combine the data
  all.data = data.frame(rbind(co2.ny, co2.london, co2.la, ch4.ny, ch4.london, ch4.la))
  
  # add locations and pollutants to the data
  all.data$location = location
  all.data$pollutant = pollutant
  
  # open the reshape2 library
  library(reshape2)
  
  # stack the data while retaining the location and pollutant label by 
  stacked.data = melt(all.data, id = c('location', 'pollutant'))
  
  # remove the column that gives the column name of the concentration from all.data
  stacked.data = stacked.data[, -3]
  
  
  # gdpaqi_boxplot = boxplot(value~location + pollutant, data = stacked.data, at = c(1, 1.8, 2.6, 6, 6.8, 7.6), xaxt='n', ylim = c(min(0, min(co2.ny, co2.london, co2.la)), max(ch4.ny, ch4.london, ch4.la, na.rm = T)), col = c('white', 'white', 'gray'))
  # axis(side=1, at=c(1.8, 6.8), labels=c('Methane (ppb)\nNumber of Collections = 100', 'Carbon Dioxide (ppb)\nNumber of Collections = 120'), line=0.5, lwd=0)
  # title('Comparing Pollution in London, Los Angeles, and New York')
  
  output$gdpaqi_boxplot <- renderPlot({
    boxplot(value~location + pollutant, data = stacked.data, at = c(1, 1.8, 2.6, 6, 6.8, 7.6), xaxt='n', ylim = c(min(0, min(co2.ny, co2.london, co2.la)), max(ch4.ny, ch4.london, ch4.la, na.rm = T)), col = c('white', 'white', 'gray'))
  })
}