## Code for Jasper's GIS module project
## using GIS to create a map of honeyguide guiding locations

############### Load packages and clean Data

#load packages
library(readr) ; library(sf) ; library(terra) ; library(raster) ; library(tmap) ; library(tidyverse) ; library(rosm) ; library(ggspatial) ; library(ggplot2) ; library(leaflet)

#read in data
#setwd("~/Desktop/GIT/Honours_Jasper/GIS/Honours_GIS")
data <- read_csv("data/data_clean copy.csv")
#View(data)

#chnage classes of some columns

#change to factor: group, guide_sex, bee, harvested, treeID 
cols1 <- c("group", 
           "guide_sex", 
           "bee", 
           "harvested", 
           "treeID")
data[cols1] <- lapply(data[cols1], as.factor)

#change to num: audio_start_indication, audio_finish_woo, indication_to_woo, dist_fp_start_to_bees, guiding_starttime, finalphasecalls_time, foundtree_time, GPSguiding_starttime,GPSguiding_endtime 
data$finalphasecalls_time <- as.POSIXct(as.numeric(data$finalphasecalls_time) * 86400, origin = "1899-12-31",tz = "UTC") #as other times are this format
cols2 <- c("audio_start_indication", 
           "audio_finish_woo", 
           "indication_to_woo",
           "dist_fp_start_to_bees",
           "guiding_starttime", 
           "finalphasecalls_time", 
           "foundtree_time", 
           "GPSguiding_starttime", 
           "GPSguiding_endtime")
data[cols2] <- lapply(data[cols2], as.numeric)
#note, that the times are now in seconds since 1970

#change GPS coords into tidy format (also changes dataset to a spatial object)
data_sf <- st_as_sf(data, coords = c("beetree_lon", "beetree_lat"), crs = 4326)

###############

############### 

