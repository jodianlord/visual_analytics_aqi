load_dataset <- function(source){
  #Read CSV File
  cities = read.csv(source, stringsAsFactors = FALSE)
  
  #Format the dates
  cities_transformed <- mutate(cities, date=as.Date(date, format="%Y/%m/%d"))
  
  cities_transformed <- mutate(cities_transformed, country=recode(country, 'United Kingdom' = 'UK', 
                                          'United States' = 'USA', 
                                          'Emirates' = 'United Arab Emirates',
                                          'Zealand' = 'New Zealand',
                                          'Bosnia' = 'Bosnia and Herzegovina',
                                          'Czechia' = 'Czech Republic',
                                          'Korea' = 'South Korea',
                                          'Africa' = 'South Africa',
                                          'Guiana' = 'French Guiana',
                                          'Lanka' = 'Sri Lanka',
                                          'Arabia' = 'Saudi Arabia',
                                          'Gibraltar' = 'gb',
                                          'Kong' = 'China',
                                          'Caledonia' = 'New Caledonia',
                                          'Rico' = 'Puerto Rico',
                                          'Rica' = 'Costa Rica',
                                          'Salvador' = 'El Salvador',
                                          'City' = 'Vatican'))
  cities_transformed <- cities_transformed[!cities_transformed$city == 'gibraltar',]
  map_world = map_data('world')
  colnames(map_world)[5] = 'country'
  
  cities_transformed <- subset(cities_transformed, select=-city)
  cities_transformed <- aggregate(cities_transformed, by=list(`date`=cities_transformed$date, country=cities_transformed$country), FUN=mean)
  
  #cities_transformed <- merge(cities_transformed, map_world, by='country')[,c("long", "lat", "country", "pm25")]
  
  return(cities_transformed)
}