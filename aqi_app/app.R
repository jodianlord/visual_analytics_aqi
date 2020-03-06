#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("AQI Index"),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("singaporeplot")
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    #Read CSV File
    cities = read.csv('all_cities.csv', stringsAsFactors = FALSE)
    
    #Format the dates
    cities_transformed <- mutate(cities, date=as.Date(date, format="%Y/%m/%d"))
    
    #Group data by month, take the mean
    cities_grouped <- cities_transformed %>%
        group_by(month=floor_date(date, "month")) %>%
        summarise(totalpm = mean(pm25))
    
    #Assign the Singapore data subset
    str(cities_transformed)
    singapore <- subset(cities_grouped, city='singapore')
    
    #Output a line plot of PM25 vs month
    output$singaporeplot <- renderPlot({
        ggplot(singapore, aes(x=month, y=totalpm)) +
            ggtitle("Average PM25 levels over Months") +
            xlab("Date") + ylab("Average PM25") + 
            scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
            theme(axis.text.x=element_text(angle=60, hjust=1)) +
            geom_line(color="red")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
