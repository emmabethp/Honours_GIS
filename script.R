## Code for Jasper's GIS module project
## using GIS to create a map of honeyguide guiding locations

############### Load packages and clean point Data

#load packages
library(readr) ; library(sf) ; library(terra) ;
library(raster) ; library(tmap) ; library(tidyverse) ;
library(rosm) ; library(ggspatial) ; library(ggplot2) ;
library(leaflet) ; library(prettymapr) ; library(htmltools)

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
trees <- st_as_sf(data, coords = c("beetree_lon", "beetree_lat"), crs = 4326)

#examine trees dataset
class(trees)
head(trees)

#check CRS 
st_crs(trees) #EPSG:4326 

#change CRS to better Mozambique CRS 
trees <- st_transform(trees, crs = "EPSG:32737")

#subset by attribute: guided to bees or other animal
trees$animal_found <- ifelse(trees$bee == "apis", "Apis", "Other")



#plot using leaflet
trees <- st_transform(trees, 4326) #first transfer crs to work with leaflet
pal <- colorFactor(palette = c("green", "red"),
                   domain = trees$animal_found) #then add colour palette
leaflet(data = trees_ll) %>%
  addProviderTiles(providers$Esri.WorldTopoMap) %>%
  addCircleMarkers(
    radius = 4,
    fillColor = ~pal(animal_found),
    color = "black",
    weight = 1,
    fillOpacity = 0.9,
    popup = ~animal_found
  ) %>%
  addLegend(
    "bottomright",
    colors = c("green", "red"),
    labels = c("Bees", "Other"),
    title = "Animal Found"
  )
