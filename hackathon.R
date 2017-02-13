#####################

### HackNUE 2017
# Project name : Eventor
# Project participant names:

#### Lauti Cantar (cantar.l@husky.neu.edu)
#### Akshay Sadarangani (4kshay@ccs.neu.edu)
#### Junchen Zhan (zhan.j@husky.neu.edu)
#### Amy (Chia-Yi) Liaw (liaw.c@husky.neu.edu)


## Libraries required to work
library(stringr)
library(rvest)
library(XML)
library(dplyr)

setwd("C:/Users/l_can/Dropbox/MS_in_Urban_Informatics/Hackaton")

## This code is used to scrape thebostoncalendar.com page. It works in the following way:
## First it scrapes the landing page of thebostoncalendar and extracts the url of each particular event.
## Secondly it scrapes each particular event URL looking for date, location, category and website.

########### URL scraper ###########

beggining <- "http://www.thebostoncalendar.com/events?day="
end <- "&month=2&year=2017"

number <- seq(from = 12, to = 28, by = 1)
start.url <- sapply(number, function(x)
  paste0(beggining, x, end))

event.detail.urls <- lapply(start.url, function(url) {
  calendar <- read_html(url)
  
  end.link  <-
    calendar %>% html_nodes("#events h3 a") %>% html_attr("href")
  first.link <- "http://www.thebostoncalendar.com"
  calendar.link <-
    sapply(end.link, function(x)
      paste0(first.link, end.link))
  #calendar.link <- paste("http://www.thebostoncalendar.com", end.link, sep="")
  calendar.link
}) %>% unlist() %>% unique()


########### Event scraper ###########

scrape.event.detail <- function(url) {
  # url.1 <- "http://www.thebostoncalendar.com/events/indo-row-hiit-workout-in-south-end--3"
  
  event <- read_html(url)
  
  event.info <- event %>% html_nodes("#event_info")
  event.name  <- event %>% html_nodes("h1") %>% html_text()
  event.time  <-
    event.info %>% html_nodes("p:nth-child(1)") %>% html_text()
  event.location  <-
    event.info %>% html_nodes("p:nth-child(2)") %>% html_text()
  event.admission  <-
    event.info %>% html_nodes("p:nth-child(3)") %>% html_text()
  event.categories  <-
    event.info %>% html_nodes("p:nth-child(4)") %>% html_text()
  event.website  <-
    event.info %>% html_nodes("p:nth-child(5)") %>% html_text()
  
  c(
    name.event = event.name,
    date.event = event.time,
    place.event = event.location,
    admission.event = event.admission,
    category.event = event.categories,
    website.event = event.website
  )
  #...
}

event.details <- lapply(event.detail.urls, scrape.event.detail)
event.details <- do.call(rbind, event.details)

## Transforming the lists into a data frame
bostoncalendar.df <- as.data.frame(event.details, stringsAsFactors=FALSE)

# Cleanning the data
bostoncalendar.df$name.event <- gsub("\\s+", " ", bostoncalendar.df$name.event)  # shrink spances 
bostoncalendar.df$name.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$name.event)  # trim head and tail spaces

bostoncalendar.df$date.event <- gsub("When:", "", bostoncalendar.df$date.event)  # Removing "When:" 
bostoncalendar.df$date.event <- gsub("\\s+", " ", bostoncalendar.df$date.event)  # shrink spances 
bostoncalendar.df$date.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$date.event)  # trim head and tail spaces

bostoncalendar.df$place.event <- gsub("Where:", "", bostoncalendar.df$place.event)  # Removing "Where:" 
bostoncalendar.df$place.event <- gsub("\\s+", " ", bostoncalendar.df$place.event)  # shrink spances 
bostoncalendar.df$place.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$place.event)  # trim head and tail spaces

bostoncalendar.df$admission.event <- gsub("Admission:", "", bostoncalendar.df$admission.event)  # removing Admission: 
bostoncalendar.df$admission.event <- gsub("\\s+", " ", bostoncalendar.df$admission.event)  # shrink spances 
bostoncalendar.df$admission.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$admission.event)  # trim head and tail spaces

bostoncalendar.df$category.event <- gsub("Categories:", "", bostoncalendar.df$category.event)  # removing "Categories:" 
bostoncalendar.df$category.event <- gsub("\\s+", " ", bostoncalendar.df$category.event)  # shrink spances 
bostoncalendar.df$category.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$category.event)  # trim head and tail spaces

bostoncalendar.df$website.event <- gsub("Event website:", "", bostoncalendar.df$website.event)  # removing "Event website:" 
bostoncalendar.df$website.event <- gsub("\\s+", " ", bostoncalendar.df$website.event)  # shrink spances 
bostoncalendar.df$website.event <- gsub("^\\s+|\\s+$", "", bostoncalendar.df$website.event)  # trim head and tail spaces

# Working with time
bostoncalendar.df$time <- lapply(strsplit(as.character(bostoncalendar.df$date.event), "2017 "), "[", 2)
bostoncalendar.df$date.event  <- paste0(lapply(strsplit(as.character(bostoncalendar.df$date.event), ", "), "[", 2), ", 2017")

bostoncalendar.df$end.time<- paste0(lapply(strsplit(as.character(bostoncalendar.df$time), "- "), "[", 2), "m")
bostoncalendar.df$time<- paste0(lapply(strsplit(as.character(bostoncalendar.df$time), "- "), "[", 1), "m")

# Working wiht location

bostoncalendar.df$state <- as.character(lapply(strsplit(as.character(bostoncalendar.df$place.event), ", "), "[", 2))
bostoncalendar.df$zip <- as.character(lapply(strsplit(as.character(bostoncalendar.df$state), " "), "[", 2))
bostoncalendar.df$state <- as.character(lapply(strsplit(as.character(bostoncalendar.df$state), " "), "[", 1))
bostoncalendar.df$place <- as.character(lapply(strsplit(as.character(bostoncalendar.df$place.event), "[[:digit:]]"), "[", 1))

# Changing the category name

bostoncalendar.df$category <- ifelse(grepl("< 21", bostoncalendar.df$category.event, ignore.case = T), "Other", 
              ifelse(grepl("Alcohol", bostoncalendar.df$category.event, ignore.case = T), "Other",
              ifelse(grepl("Art", bostoncalendar.df$category.event, ignore.case = T), "Arts",
              ifelse(grepl("Business", bostoncalendar.df$category.event, ignore.case = T), "Business",
              ifelse(grepl("Date Idea", bostoncalendar.df$category.event, ignore.case = T), "Other",
              ifelse(grepl("Festivals & Fairs", bostoncalendar.df$category.event, ignore.case = T), "Home & Lifestyle",
              ifelse(grepl("Film", bostoncalendar.df$category.event, ignore.case = T), "Film & Media",
              ifelse(grepl("Food", bostoncalendar.df$category.event, ignore.case = T), "Food & Drink",
              ifelse(grepl("Innovation", bostoncalendar.df$category.event, ignore.case = T), "Community",
              ifelse(grepl("Kid Friendly", bostoncalendar.df$category.event, ignore.case = T), "Family & Education",
              ifelse(grepl("Lectures & Conferences", bostoncalendar.df$category.event, ignore.case = T), "Family & Education",
              ifelse(grepl("LGBT", bostoncalendar.df$category.event, ignore.case = T), "Other",
              ifelse(grepl("Meetup", bostoncalendar.df$category.event, ignore.case = T), "Hobbies",
              ifelse(grepl("Music", bostoncalendar.df$category.event, ignore.case = T), "Music",
              ifelse(grepl("Nightlife", bostoncalendar.df$category.event, ignore.case = T), "Hobbies",
              ifelse(grepl("Party", bostoncalendar.df$category.event, ignore.case = T), "Hobbies",
              ifelse(grepl("Performing Arts", bostoncalendar.df$category.event, ignore.case = T), "Arts",
              ifelse(grepl("Social Good", bostoncalendar.df$category.event, ignore.case = T), "Charity & Causes",
              ifelse(grepl("Sports & Active Life", bostoncalendar.df$category.event, ignore.case = T), "Sports & Fitness",
              ifelse(grepl("Tech", bostoncalendar.df$category.event, ignore.case = T), "Science & Tech",
              ifelse(grepl("University", bostoncalendar.df$category.event, ignore.case = T), "Family & Education",0)))))))))))))))))))))


## Exporting the data set
write.csv(bostoncalendar.df, "boston.calendar.csv", row.names = FALSE)




