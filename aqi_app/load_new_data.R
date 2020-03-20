map_world = map_data('world')
load_dataset <- function(){
  countries = read.csv('data/EXP_PM2_5_14032020074440630.csv', stringsAsFactors = FALSE)
  
  #countries <- subset(countries, Year == "2000")
  #countries <- subset(countries, Variable == "Mean population exposure to PM2.5")
  #countries <- mutate(countries, Year=as.Date(ISOdate(Year, 1, 1)))
  countries <- subset(countries, Macroregion == '-Total-')
  countries <- dplyr::select(countries, Country, Variable, Year, Unit, Value)
  countries <- subset(countries, !(Country %in% c("G7", "World", "ASEAN", "G20", 
                                                  "BRIICS economies - Brazil, Russia, India, Indonesia, China and South Africa", 
                                                  "European Union (28 countries)",
                                                  "OECD - Total", "OECD America", "Eastern Europe, Caucasus and Central Asia",
                                                  "Latin America and Caribbean", "Middle East and North Africa",
                                                  "United States Virgin Islands")))
  
  countries <- mutate(countries, Country=recode(Country,'Korea' = 'South Korea',
                                                'Slovak Republic' = 'Slovakia',
                                                'United Kingdom' = 'UK',
                                                'United States' = 'USA',
                                                'Antigua and Barbuda' = 'Antigua',
                                                'Brunei Darussalam' = 'Brunei',
                                                'Cabo Verde' = 'Cape Verde',
                                                "China (People's Republic of)" = 'China',
                                                'Congo' = 'Democratic Republic of the Congo',
                                                "Democratic People's Republic of Korea" = 'North Korea',
                                                "Lao People's Democratic Republic" = 'Laos',
                                                'North Macedonia' = 'Macedonia',
                                                'Saint Vincent and the Grenadines' = 'Saint Vincent',
                                                'Eswatini' = 'Swaziland',
                                                'Syrian Arab Republic' = 'Syria',
                                                'Trinidad and Tobago' = 'Trinidad',
                                                'Viet Nam' = 'Vietnam'))
  #countries <- anti_join(countries, map_world, by = c('Country' = 'region'))
  #countries <- merge(countries, map_world, by.x = "Country", by.y = "region")
  countries <- right_join(map_world, countries, by=c('region' = 'Country'))
  #write.csv(countries, "data/pollutant_with_coordinates.csv", row.names = FALSE)
  return(countries)
}

load_maps <- function(){
  return(map_world)
}

load_policies <- function() {
  policies <- readxl::read_xlsx('data/policies.xlsx')
  return(policies)
}

load_pollution <- function() {
  countries <- load_dataset()
  df <- subset(countries, countries$Variable == "Mean population exposure to PM2.5")
  df <- df[, !names(df) %in% c(
    'lat',
    'long',
    'group',
    'order',
    'subregion',
    'Variable',
    'Unit'
  )]
  df <- aggregate(cbind(value=df$Value), list(region = df$region, year = df$Year), mean)
  return(df)
}