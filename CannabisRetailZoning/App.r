library(rgeos)
library(rgdal)
require(maptools)
library(leaflet)
library(dplyr)
spToGeoJSON <- function(x){
  # Return sp spatial object as geojson by writing a temporary file.
  # It seems the only way to convert sp objects to geojson is 
  # to write a file with OGCGeoJSON driver and read the file back in.
  # The R process must be allowed to write and delete temporoary files.
  #tf<-tempfile('tmp',fileext = '.geojson')
  tf<-tempfile()
  writeOGR(x, tf,layer = "geojson", driver = "GeoJSON")
  js <- paste(readLines(tf), collapse=" ")
  file.remove(tf)
  return(js)
}

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
                  numericInput("feetbuffer", label = h3("Buffer in feet"), 1000)
                  )
    )

server <- function(input, output, session) {
  filteredData <- reactive({
    load("map.rda") 
    map <- spTransform( map, CRS( "+init=epsg:26934" ) )  
    map <- gBuffer(map, width = input$feetbuffer / 3.28084)
    map <- spTransform( map , CRS("+proj=longlat"))
    as(map, "SpatialPolygonsDataFrame")
  })
  output$map <- renderLeaflet({
    leaflet() %>% addTiles(urlTemplate = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>% setView(-149.85, 61.15, zoom = 12) %>%
      addGeoJSON(spToGeoJSON(filteredData()))
  })
  observe({
    leafletProxy("map", data = filteredData()) 
  })
}
  
shinyApp(ui, server)
