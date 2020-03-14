load_dataset <-function(source){
  #Read CSV File
  cities = read.csv(source, stringsAsFactors = FALSE)
  
  #Format the dates
  cities_transformed <- mutate(cities, date=as.Date(date, format="%Y/%m/%d"))
  
  #Group data by month, take the mean
  cities_grouped <- cities_transformed %>%
    group_by(month=floor_date(date, "month")) %>%
    summarise(totalpm25 = mean(pm25), totalpm10 = mean(pm10))
  
  return(cities_grouped)
  
  #Assign the Singapore data subset
  #str(cities_transformed)
  #singapore <- subset(cities_grouped, city='singapore')
}