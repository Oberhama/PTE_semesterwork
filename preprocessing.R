library(tidyr)
library(readr)
library(sf)
library(tmap)
library(purrr)
library(ggplot2)
library(dplyr)


### READ ALL FILES ###

# get all .plt files
files <- list.files(
  "Data/Raw",
  pattern = "\\.plt$",
  full.names = TRUE
)

# read all files into separate variables
counter <- 1

for(i in seq_along(files)) {
  
  # read trajectory first
  traj <- read_csv(
    files[i],
    skip = 6,
    col_names = c(
      "lat",
      "lon",
      "unused",
      "altitude_ft",
      "days",
      "date",
      "time"
    ),
    show_col_types = FALSE
  ) %>%
    mutate(
      datetime = as.POSIXct(
        paste(date, time),
        format = "%Y-%m-%d %H:%M:%S",
        tz = "UTC"
      )
    )
  
  # skip files with more than 5000 rows
  if(nrow(traj) > 5000) {
    cat("Skipping", files[i], "- too many rows\n")
    next
  }
  
  # create variable name only for kept trajectories
  obj_name <- sprintf("traj_%03d", counter)
  
  # assign into global environment
  assign(obj_name, traj)
  
  counter <- counter + 1
}


### VISUALIZE ALL TRAJECTORIES ###
traj_names <- ls(pattern = "^traj_")

# convert all trajectories to sf LINESTRINGs
traj_lines <- map(
  traj_names,
  function(x) {
    
    traj <- get(x)
    
    # convert to sf points
    traj_sf <- st_as_sf(
      traj,
      coords = c("lon", "lat"),
      crs = 4326
    )
    
    # convert points to line
    traj_line <- traj_sf %>%
      summarise(do_union = FALSE) %>%
      st_cast("LINESTRING")
    
    traj_line$trajectory <- x
    
    traj_line
  }
)

# combine all lines into one sf object
traj_all <- do.call(rbind, traj_lines)

# interactive mode
tmap_mode("view")

# map
tm_shape(traj_all) +
  tm_lines(
    col = "blue",
    lwd = 2
  )


### EXTRACT ACTIVE TRAVEL PARTS ###

timeToNextPoint5min <- function(traj_x) {
  # make sure ordered by time
  traj_x <- traj_x[order(traj_x$datetime), ]
  n <- nrow(traj_x)
  # output vector
  time_to_next_5min <- rep(NA_real_, n)
  for(i in 1:n) {
    current_time <- traj_x$datetime[i]
    # time differences in seconds
    diffs <- as.numeric(
      difftime(
        traj_x$datetime[(i+1):n],
        current_time,
        units = "secs"
      )
    )
    # first point at least 5 min (=300 sec) ahead
    idx <- which(diffs >= 300)[1]
    if(!is.na(idx)) {
      time_to_next_5min[i] <- diffs[idx]
    }
  }
  # add column
  traj_x$timeToNextPoint5min_sec <- time_to_next_5min
  return(traj_x)
}

distToNextPoint5min <- function(traj_x) {
  # make sure ordered by time
  traj_x <- traj_x[order(traj_x$datetime), ]
  n <- nrow(traj_x)
  # output vector
  time_to_next_5min <- rep(NA_real_, n)
  for(i in 1:n) {
    current_time <- traj_x$datetime[i]
    # time differences in seconds
    diffs <- as.numeric(
      difftime(
        traj_x$datetime[(i+1):n],
        current_time,
        units = "secs"
      )
    )
    # first point at least 5 min (=300 sec) ahead
    idx <- which(diffs >= 300)[1]
    if(!is.na(idx)) {
      time_to_next_5min[i] <- diffs[idx]
    }
  }
  # add column
  traj_x$timeToNextPoint5min_sec <- time_to_next_5min
  return(traj_x)
}

distToNextPoint5min <- function(traj_x) {
  # ensure ordering
  traj_x <- traj_x[order(traj_x$datetime), ]
  n <- nrow(traj_x)
  # output vector (meters)
  dist_to_next_5min <- rep(NA_real_, n)
  # convert to sf points (WGS84)
  sf_pts <- st_as_sf(traj_x, coords = c("lon", "lat"), crs = 4326)
  # loop over points
  for(i in 1:n) {
    current_time <- traj_x$datetime[i]
    # find future points
    future_idx <- which(traj_x$datetime > current_time)
    if(length(future_idx) == 0) next
    # time diffs (seconds)
    dt <- as.numeric(difftime(traj_x$datetime[future_idx],
                              current_time,
                              units = "secs"))
    # first index >= 5 minutes
    j <- which(dt >= 300)[1]
    if(!is.na(j)) {
      target_idx <- future_idx[j]
      # distance in meters using sf
      dist <- st_distance(sf_pts[i, ], sf_pts[target_idx, ], by_element = TRUE)
      dist_to_next_5min[i] <- as.numeric(dist)
    }
  }
  traj_x$distToNextPoint5min_m <- dist_to_next_5min
  return(traj_x)
}

speedToNextPoint5min <- function(traj_x){
  traj_x$speedToNextPoint5min_ms <- traj_x$distToNextPoint5min_m / traj_x$timeToNextPoint5min_sec
  traj_x$distToNextPoint5min_m[is.na(traj_x$speedToNextPoint5min_ms)] <- NA
  return(traj_x)
}

# speed threashold: 0.833 m/s (=3km/h)
travelling <- function(traj_x) {
  traj_x$travelling <- traj_x$speedToNextPoint5min_ms >= 0.833
  traj_x$travelling[is.na(traj_x$speedToNextPoint5min_ms)] <- NA
  
  return(traj_x)
}

extractMovingSegment <- function(traj_x) {
  # find all TRUE positions
  moving_idx <- which(traj_x$travelling == TRUE)
  # if no movement exists
  if(length(moving_idx) == 0) {
    return(NULL)
  }
  # first moving point
  start_idx <- moving_idx[1]
  # find first FALSE after movement started
  after_start <- traj_x$travelling[start_idx:nrow(traj_x)]
  end_false <- which(after_start == FALSE)[1]
  # determine end index
  if(is.na(end_false)) {
    end_idx <- nrow(traj_x)
  } else {
    end_idx <- start_idx + end_false - 2
  }
  # return only consecutive moving segment
  traj_moving <- traj_x[start_idx:end_idx, ]
  return(traj_moving)
}

#traj_test <- traj_002
#traj_test <- timeToNextPoint5min(traj_test)
#traj_test <- distToNextPoint5min(traj_test)
#traj_test <- speedToNextPoint5min(traj_test)
#traj_test <- travelling(traj_test)
#traj_test2 <- extractMovingSegment(traj_test)

for(nm in traj_names) {
  
  cat("Processing", nm, "...\n")
  
  
  
  # load trajectory
  traj <- get(nm)
  
  # processing pipeline
  traj <- timeToNextPoint5min(traj)
  traj <- distToNextPoint5min(traj)
  traj <- speedToNextPoint5min(traj)
  traj <- travelling(traj)
  
  # extract moving segment
  traj_moving <- extractMovingSegment(traj)
  
  # save objects in workspace
  assign(nm, traj)
  assign(paste0(nm, "_moving"), traj_moving)
  
  # export to csv
  write.csv(
    traj_moving,
    file = file.path(
      "Data/Preprocessed",
      paste0(nm, "_moving.csv")
    ),
    row.names = FALSE
  )
}




