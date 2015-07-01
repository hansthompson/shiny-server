library(shiny)
library(leaflet)
load("data/all_the_data.rda")

precincts <- levels(factor(all_the_data$NAME))

#input <- list(select = "Spenard")



head(all_the_data)

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
                  selectInput("select", label = h3("Select box"), 
                              choices = precincts, 
                              selected = "Spenard")
                  )
    )
)

server <- function(input, output, session) {
    
    # Reactive expression for the data subsetted to what the user selected
    filteredData <- reactive({
         all_the_data %>% filter(as.character(NAME) == input$select) %>% select(x, y) %>%
            rename(lng = x, lat = y)
    })

    
    output$map <- renderLeaflet({
        # Use leaflet() here, and only include aspects of the map that
        # won't need to change dynamically (at least, not unless the
        # entire map is being torn down and recreated).
        leaflet(data = filteredData()) %>% addTiles() %>% addProviderTiles("Stamen.Toner") %>% addMarkers() 
    })
    
    # Incremental changes to the map (in this case, replacing the
    # circles when a new color is chosen) should be performed in
    # an observer. Each independent set of things that can change
    # should be managed in its own observer.
    observe({
        
        leafletProxy("map", data = filteredData()) 
    })
    
}
1
shinyApp(ui, server)