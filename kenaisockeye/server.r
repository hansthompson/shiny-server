library(ggplot2)
library(dplyr)
library(shiny)
library(lubridate)
library(stringr)
library(gridExtra)
library(RCurl)


shinyServer(function(input, output) {  

  ########LOAD SONAR#######
  load("data/sonar.rda")
  ########GET REALTIME#####
  load("data/rt_dat.rda")
  ########TEST FISH########
  load("data/testFish.rda")

  #input <- list(year = c(2002,2012), 
  #              start_date = "06-30", 
  #              end_date = "08-05")
  
  sonar_reactive <- reactive({
    year(sonar$date) <- 2014
    start_year <- input$year[1]
    end_year   <- input$year[2]
    start_date <- ymd(paste("2014", input$start_date, sep = "-"))
    end_date   <- ymd(paste("2014", input$end_date, sep = "-"))
  
    sonar %>% 
      filter(year >= start_year, year <= end_year, 
             date >= start_date,
             date <= end_date
  )
    
  #sonar_reactive <- sonar
  })
  
  
  
  realtime_reactive <- reactive({
    return(rt_dat2)
    #realtime_reactive <- rt_dat
  })
  ########################  

  #######PLOTING#########
  prior_barchart <- reactive({
    p <- ggplot(data = sonar_reactive(), aes(x = date, y = n, group = year, fill = factor(year))) + 
         geom_bar(stat = "identity") + ylab("Daily Count") + xlab("Date")
    return(p)    
  })
  
  realtime_chart <- reactive({
    ylimit <- max(realtime_reactive()$cfue_estimates)
    p <- ggplot(data = realtime_reactive(), aes(x = Date, y = cfue_estimates)) +   
      ylim(c(0, ylimit) * 1.1) +
      #xlim(c(real_tim$date[1], future)) 
      geom_line(aes(color = "red"), size = 3) +   
      #stat_smooth(  method = "lm", 
      #              formula = y ~ poly(x, 4), 
      #              level = 0.95,
      #              fullrange = FALSE,
      #              se = TRUE,
      #              aes(colour = "black")) +
      theme(legend.position="none") +
      ggtitle("Predicted Catch Per Effort") +
      ylab("Predicted Sockeye Catch Per Day") 
    return(p)
  })
  
  testFishReactive <- reactive({
    p <- ggplot(data = testFish, aes(x = Date, y = StationCount, color = allIDs, fill = allIDs)) +
           geom_bar(stat = "identity") +
           ggtitle("Total Test Fish Caught in Cook Inlet") +
           ylab("Total Fish") +
           annotate("text",
                    x=unique(testFish$Date[testFish$Comment != ""]),
                    y=1,
                    label="*", size = 8) + 
           theme(legend.title=element_blank())
  
    return(p) 
  })

    #########################

  ######Publishing#########

  ###TABSET: REAL TIME#####
  #output$realtime <- renderPlot({
  #  print(realtime_chart())
  #})

  output$realtime <- renderPlot({
  x <- getURL("http://www.adfg.alaska.gov/sf/FishCounts/index.cfm?ADFG=export.excel&countLocationID=40&year=2015,2014&speciesID=420")
  this_season <- read.csv(text = x, sep = "\t")
  this_season$count_date <- ymd(paste(this_season$year, this_season$count_date))
  
  ggplot(this_season, aes(x = count_date, y = fish_count)) + geom_bar(stat = "identity") + 
    ylab("Fish Count") + xlab("Date in 2015") + ggtitle("This Season's Kenai Sockeye Return")
  })
  

  output$testFishery <- renderPlot({
    print(testFishReactive())
  })

  output$testFisheryComments <- renderPlot({
    grid.table(d = unique(testFish[testFish$Comment != "", c(2, 9)]),
               show.rownames = FALSE)
  })
  
  ###TABSET: PRIOR DATA####
  output$linechart <- renderPlot({
    print(prior_linechart())
  })

  output$barchart <- renderPlot({
    p <- prior_barchart()
    print(p)
  })

})
  ##TABSET: ABOUT