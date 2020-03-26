# Import packages
library(ggplot2)

# Visualise Prepost graph
prepost_visualise <- function(input, output, pollution, policies) {
  output$prepostplot = renderPlotly({
    # Get pollution for that country
    pollution_sub <- subset(pollution, country == input$country)
    
    # Get policies for this country
    policies_sub <- subset(policies, policies$country == input$country  &
                             policies$policy_name %in% input$policies_selected)[, c('policy_name', 'date')]
    
    get_vlines = function() {
      if (dim(policies_sub)[1] == 0) {
        return(NULL)
      }
      return(geom_vline(data=policies_sub, mapping=aes(xintercept=date), color="blue"))
    }
    
    get_vline_labels = function() {
      if (dim(policies_sub)[1] == 0) {
        return(NULL)
      }
      return(geom_text(data=policies_sub, mapping=aes(x=date, y=0, label=policy_name), size=3, angle=90, vjust=-0.4, hjust=0))
    }
    str("It still works up to here")
    str(pollution_sub)
    # Plot
    ggplot(pollution_sub, aes(x=year, y=value)) +
      geom_line(colour='grey') +
      geom_point() +
      get_vlines() +
      get_vline_labels() +
      expand_limits(y=0) +
      ggtitle('Mean PM2 Index') +
      xlab('Year') +
      ylab('PM2 Index')
  })
}

# Helper: Filter relevant policies given country and date range
filter_policies <- function(policies, country, date_range) {
  policies_subset = subset(policies, country == country)
  return(unique(policies_subset$policy_name))
}