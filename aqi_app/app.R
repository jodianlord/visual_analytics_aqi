library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)

# Define UI for application
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
        summarise(totalpm25 = mean(pm25), totalpm10 = mean(pm10))
    
    #Assign the Singapore data subset
    str(cities_transformed)
    singapore <- subset(cities_grouped, city='singapore')
    
    
    
    #Output a line plot of PM25 vs month
    output$singaporeplot <- renderPlot({
        ggplot(singapore, aes(x=month)) +
            ggtitle("Average PM25 and PM10 levels over Months") +
            xlab("Date") + ylab("Pollutant Levels") + 
            scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
            theme(axis.text.x=element_text(angle=60, hjust=1)) +
            geom_line(aes(y=totalpm25), color="red") +
            geom_line(aes(y=totalpm10), color="blue")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
