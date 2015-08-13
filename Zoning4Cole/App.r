library(rgeos)
library(rgdal)
library(leaflet)
library(geojsonio)
load("map.rda") 

ui <- bootstrapPage(title = "Cannabis Cafe Zoning",
                    tags$head(includeScript("google-analytics.js")),
                    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                    leafletOutput("map", width = "100%", height = "100%"),
                    absolutePanel(class = "panel panel-default",top = 10, right = 10, width = 330,
                                  p("Since several successful initiaitves in serveral states to legalize the retail sale of Cannabis, local communities have been proposing and enacting zoning laws distancing new stores from schools and daycares. This interactive map of Anchorage allows you to simulate the effect of this kind of zoning law."),  
                                  p("Using publicly available parcel data from 2014 for over 200 zoned schools and daycares you can visualize the effect that different distance buffers would have on where Anchorage's first marijuana cafes could be."),                  
                                  numericInput("feetbuffer", label = h4("Buffer From Parcel (ft.)"), 1000),
                                  actionButton("updateButton", "Update")
                    )
)

server <- function(input, output, session) {
  filteredData <- eventReactive(input$updateButton, {
    spTransform(map, CRS("+init=epsg:26934")) %>%  
      gBuffer(width = input$feetbuffer / 3.28084) %>%
      spTransform(CRS("+proj=longlat")) %>%
      as("SpatialPolygonsDataFrame")
  })
  output$map <- renderLeaflet({
    leaflet() %>% addTiles(urlTemplate = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>% setView(-149.85, 61.15, zoom = 12) %>%
      addGeoJSON(geojson_json((filteredData())))
  })
  observe({
    leafletProxy("map", data = filteredData()) 
  })
}

shinyApp(ui, server)