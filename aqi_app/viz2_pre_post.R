# Import packages
library('tidyverse')

# Import data
df = read_csv('all_cities.csv')

# Plot time series
ggplot(data = df, aes(date, pm25)) +
  geom_line() +
  xlab('Date') +
  ylab('pm25')