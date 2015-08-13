library(shinythemes)
library(rgeos)
library(rgdal)
library(leaflet)
library(geojsonio)
load("map.rda") 

ui <- bootstrapPage(theme = shinytheme("spacelab"),
                    title = "Cannabis Business Zoning",
                    tags$head(includeScript("google-analytics.js")),
                    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                    leafletOutput("map", width = "100%", height = "100%"),
                    absolutePanel(class = "panel panel-default",top = 10, right = 10, width = 330,
                                  includeMarkdown("docs/about.md"),
                                  numericInput("feetbuffer", label = h4("Feet From Facility"), 500),
                                  actionButton("updateButton", "Update"),
                                  br(),
                                  a(img(src = "codeforanc.png"), href = "http://codeforanchorage.org/")
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