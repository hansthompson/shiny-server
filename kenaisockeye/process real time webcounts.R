library(XML)
library(lubridate)


download.file(url = "https://www.adfg.alaska.gov/sf/FishCounts/index.cfm?ADFG=export.excel&countLocationID=40&year=2015,2014&speciesID=420",
              destfile = "this_seasons_sockeye_count.csv")
this_season <- read.csv("this_seasons_sockeye_count.csv", sep = "\t")
this_season$count_date <- ymd(paste(this_season$year, this_season$count_date))

ggplot(this_season, aes(x = count_date, y = fish_count)) + geom_bar(stat = "identity") + 
  ylab("Fish Count") + xlab("Date in 2015") + ggtitle("This Season's Kenai Sockeye Return")


