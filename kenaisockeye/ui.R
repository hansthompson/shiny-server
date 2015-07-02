library(shiny)
library(ggplot2)
# Define UI for application that plots random distributions 
shinyUI(fluidPage(
  
  # Application title
  headerPanel("Dipnet_App! - IN BETA"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
  
  wellPanel(
    #helpText("Hi. Play around with the inputs to subset the historical data or look at the predictions."),
    sliderInput("year", "Years of Interest", min = 1979, max = 2012, value = c(2002, 2012), sep = ""),
    textInput("start_date", "Start Date:", "06-30"),
    textInput("end_date", "End Date:", "08-05")
  ),
  wellPanel(   
    img(src = "codeforanc.png"),
    helpText("")
    ),
  wellPanel(
      helpText(HTML("<b>VERSION CONTROL</b>")),
      HTML('Version 0.9.0'),
      HTML('<br>'),
      HTML('Deployed on June 3rd, 2014'),
      HTML('<br>'),
      HTML('<a href="https://github.com/hansthompson/shiny-server/tree/master/kenaisockeye" target="_blank">Code on GitHub</a>')
    ) 

  ),
  
  mainPanel(
    
    tabsetPanel(
      tabPanel("2015 Real Time", 
               plotOutput("realtime"),
               plotOutput("testFishery"),
               plotOutput("testFisheryComments")
      ), 
      tabPanel("Prior Sonar Counts", 
               plotOutput("barchart")),
      tabPanel("About", includeMarkdown("docs/introduction.md"))
               
      ) 
    )
    
  )
)