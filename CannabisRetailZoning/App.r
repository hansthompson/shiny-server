library(rgeos)
library(rgdal)
library(leaflet)
load("map.rda") 
spToGeoJSON <- function(x){
  tf<-tempfile()
  writeOGR(x, tf,layer = "geojson", driver = "GeoJSON")
  js <- paste(readLines(tf), collapse=" ")
  file.remove(tf)
  return(js)
}

ui <- bootstrapPage(
    tags$head(includeScript("google-analytics.js")),
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
                  numericInput("feetbuffer", label = h3("Buffer In Feet"), 1000)
                  )
    )

server <- function(input, output, session) {
  filteredData <- reactive({
    spTransform(map, CRS("+init=epsg:26934")) %>%  
     gBuffer(width = input$feetbuffer / 3.28084) %>%
     spTransform(CRS("+proj=longlat")) %>%
     as("SpatialPolygonsDataFrame")
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