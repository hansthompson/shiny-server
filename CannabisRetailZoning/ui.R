library(shiny)
library(leaflet)

shinyUI(fluidPage(navbarPage(title = "Anchorage Cannabis Cafe Zoning",
                             tabPanel("Map", 
                                      tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                                      leafletOutput("map", width = "100%", height = "100%"),
                                      absolutePanel(top = 10, right = 10,
                                                    numericInput("feetbuffer", label = h3("Buffer in feet"), 1000)
                                      )),
                             tabPanel("About", p())
)))
