library(jsonlite)
library(readr)
library(parallel)
library(doParallel)
library(igraph)

stations <- lapply(readLines("data-stations-202106.json"), fromJSON, flatten = TRUE)
stations <- stations[[1]]$stations
stations <- stations[, c(13, 10, 5, 8, 11)]
colnames(stations)[which(names(stations) == "id")] <- "name"
stations <- subset(stations, stations$name != 123)
stations <- subset(stations, stations$name != 124)

json_raw   <- readr::read_file("data-users-202106.json")
json_lines <- unlist(strsplit(json_raw, "\\n"))
trips    <- do.call(rbind, mclapply(json_lines, 
                                    FUN = function(x){as.data.frame(jsonlite::fromJSON(x))}))
colnames(trips)[which(names(trips) == "idunplug_station")] <- "from"
colnames(trips)[which(names(trips) == "idplug_station")] <- "to"
trips <- subset(trips, trips$to != 2009 & trips$from != 2009)
trips <- trips[,-c(1,2, 3, 5)]
trips <- trips[, c(3, 5, 2, 1, 4, 6, 7)]


indexes <- sample(nrow(trips), size=10000)
bicimad <- graph_from_data_frame(d=trips[indexes,], directed=T, vertices=stations)
