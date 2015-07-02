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

    foo <- sonar
    year(foo$date) <- 2015
    average_sonar <- foo %>% group_by(date) %>% summarize(mean = mean(n)) 
    
      
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
  x <- getURL("http://www.adfg.alaska.gov/sf/FishCounts/index.cfm?ADFG=export.excel&countLocationID=40&year=2015&speciesID=420")
  this_season <- read.csv(text = x, sep = "\t")
  this_season$count_date <- ymd(paste(this_season$year, this_season$count_date))
  blank <- this_season[1,] 
  blank$fish_count <- 0
  blank$count_date <- blank$count_date - days(1)
  this_season <- rbind(this_season, blank)
  
  ggplot(data = average_sonar, aes(x = date, y = mean)) + geom_line() +
     geom_bar(data = this_season, aes(x = count_date, y = fish_count), fill = "red", stat = "identity") + 
     ylab("Fish Count") + xlab("Date in 2015") + ggtitle("Kenai River Sockeye")  + 
     geom_vline(xintercept = as.numeric(ymd("2015-07-10")), linetype = "dashed", colour="#000099") +
     geom_vline(xintercept = as.numeric(ymd("2015-07-31")), linetype = "dashed", colour="#000099")
      
  })
  

  #output$testFishery <- renderPlot({
  #  print(testFishReactive())
  #})

  #output$testFisheryComments <- renderPlot({
  #  grid.table(d = unique(testFish[testFish$Comment != "", c(2, 9)]),
  #             show.rownames = FALSE)
  #})
  
  ###TABSET: PRIOR DATA####
  output$linechart <- renderPlot({
    print(prior_linechart())
  })

  output$barchart <- renderPlot({
    p <- prior_barchart()
    print(p)
  }, height = 600)

})
  ##TABSET: ABOUT