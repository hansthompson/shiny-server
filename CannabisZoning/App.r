library(shinythemes)
library(rgeos)
library(rgdal)
library(leaflet)
library(geojsonio)

load("map.rda") 
load("zones.rda")
zones_filtered <- zones

ui <- bootstrapPage(theme = shinytheme("spacelab"),
                    title = "Cannabis Business Zoning",
                    tags$head(includeScript("google-analytics.js")),
                    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                    leafletOutput("map", width = "100%", height = "100%"),
                    absolutePanel(class = "panel panel-default",top = 10, right = 10, width = 330,
                                  includeMarkdown("docs/about.md"),
                                  numericInput("feetbuffer", label = h4("Feet From Facility"), 500),
                                  selectInput("zones", "Specific Zone", as.character(levels(zones@data$ZONING_DES))),
                                  actionButton("updateButton", "Update"),
                                  br(),br(),
                                  a(img(src = "codeforanc.png"), href = "http://codeforanchorage.org/"),
                                  br(),br(),
                                  (a("Contact", href = "mailto:hans.thompson1@gmail.com"))
                                  )
                )


server <- function(input, output, session) {
  buffers <- eventReactive(input$updateButton, {
    spTransform(map, CRS("+init=epsg:26934")) %>%  
      gBuffer(width = input$feetbuffer / 3.28084) %>%
      spTransform(CRS("+proj=longlat")) %>%
      as("SpatialPolygonsDataFrame")
  })
  filteredZones <- eventReactive(input$updateButton, {
    zones_filtered@data <- zones@data[zones@data == input$zone,]
    return(zones_filtered)
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% addTiles(urlTemplate = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>% setView(-149.85, 61.15, zoom = 12) %>%
      addGeoJSON(geojson_json((buffers()))) + addGeoJSON(geojson_json(filteredZones()))
  })
  observe({
    leafletProxy("map", data = buffers()) 
  })
}

shinyApp(ui, server)