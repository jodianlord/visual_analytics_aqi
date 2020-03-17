load_dataset <- function(){
  countries = read.csv('data/EXP_PM2_5_14032020074440630.csv', stringsAsFactors = FALSE)
  map_world = map_data('world')
  
  countries <- mutate(countries, Year=as.Date(ISOdate(Year, 1, 1)))
  countries <- dplyr::select(countries, Country, Variable, Year, Unit, Value)
  countries <- subset(countries, Country != 'G7')
  
  countries <- mutate(countries, Country=recode(Country,'Korea' = 'South Korea',
                                                'Slovak Republic' = 'Slovakia',
                                                'United Kingdom' = 'UK',
                                                'United States' = 'USA'))
  countries <- anti_join(countries, map_world, by = c('Country' = 'region'))
  return(countries)
}