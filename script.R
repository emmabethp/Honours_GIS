## Code for Jasper's GIS module project
## using GIS to create a map of honeyguide guiding locations

#load packages
library(readr) ; library(sf) ; library(terra) ;
library(raster) ; library(tmap) ; library(tidyverse) ;
library(rosm) ; library(ggspatial) ; library(ggplot2) ;
library(leaflet) ; library(prettymapr) ; library(htmltools); library(htmlwidgets)

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

#call apis= bee
trees$bee <- recode(trees$bee, "apis" = "Bees")

#check CRS 
st_crs(trees) #EPSG:4326, correct for leaflet map

#subset by attribute: guided to bees or other animal
trees$animal_found <- ifelse(trees$bee == "Bees", "Bees", "Other")

#add colour palette
pal <- colorFactor(palette = c("green", "red"), domain = trees$animal_found) 

#plot using leaflet
map <- leaflet(data = trees) %>%
  addProviderTiles(
    providers$Esri.WorldTopoMap,
    group = "Esri World Topographic Map"
  ) %>%
  addProviderTiles(
    providers$Esri.WorldImagery,
    group = "Satellite Image"
  ) %>%
  addProviderTiles(
    providers$OpenTopoMap,
    group = "OSM and SRTM Topographic Map"
  ) %>%
  addCircleMarkers(
    radius = 4,
    fillColor = ~pal(animal_found),
    color = "black",
    weight = 1,
    fillOpacity = 0.75,
    popup = ~paste(
      "<strong>Animal:</strong>", bee, "<br/>",
      "<strong>Date:</strong>", date, "<br/>",
      "<strong>Guide Age:</strong>", guide_age, "<br/>",
      "<strong>Guide Sex:</strong>", guide_sex, "<br/>",
      "<strong>Guiding Distance (m):</strong>", follow_trackdist, "<br/>",
      "<strong>Guiding Time (mins):</strong>", round(guiding_totaltime,2), "<br/>"
    )
  ) %>%
  addLegend(
    "bottomright",
    colors = c("green", "red"),
    labels = c("Bees", "Other"),
    title = "Animal Found"
  ) %>%
addLayersControl(
  baseGroups = c("Esri Topographic Map", "Satellite Image", "OSM and SRTM Topographic Map"),
  options = layersControlOptions(collapsed = FALSE)
  )

#save map
saveWidget(map, "map.html", selfcontained = TRUE)