
library(data.table)
library(tidyverse)
library(future)
library(leaflet)
library(lubridate)


df <- fread("C:/Users/Disha/Desktop/ShinyProject/appsilon/ships.csv")
object.size(df)

fdf <- df[, c(1, 2, 3, 6, 7, 9, 11, 14, 15, 18, 20)]
object.size(fdf)

names(df)

max_dist_obs <- function(df)
{
  # The first part of the function is used to arrange data in ascending order, then compute
  # difference between Datetime column  and finally compute the distance
  
  df <- arrange(df, DATETIME)
  df <- mutate(df, Date_Tm_lag1_sec = as.duration(DATETIME - lag(DATETIME)),
                   Dist_mt          = as.numeric(SPEED * Date_Tm_lag1_sec * 0.5144), ## converting speed in knots and time in secs to distance in meters.
                   Dist_lag1_mt     = Dist_mt - lag(Dist_mt))
  
  # This part of the program calculate the observations that take max time and one previous observation,
  #In case there are multiple observation with the maximum time the most recent observation is chossen
  
  #l = length(df$Dist_lag1_mt) 
  #print(l)
  max_value <- max(df$Dist_lag1_mt, na.rm = TRUE)
  num_max <- which(df$Dist_lag1_mt == max_value)
  
  element_2 <- list()
  
  for (i in seq_along(num_max)) {
    if (length(num_max) == 1) {
      element_2[[i]] <- df %>% dplyr::slice((num_max[[i]] - 1):num_max[[i]])
      
      
    }
    else{
      
      df1 <- df %>%
        dplyr::filter(Dist_lag1_mt == max_value)
      num_max1 <- which.max(df1$DATETIME)
      element_2[[i]] <-
        df1 %>% dplyr::slice((num_max1 - 1):num_max1)
      break
      
    }
    
  }
  
  bind_rows(element_2)
}

plan(multisession)

grouped_data <- fdf %>%
  group_nest(ship_type, SHIPNAME, DESTINATION, keep = TRUE)


base2 <- map(grouped_data$data, max_dist_obs)


base3 <- bind_rows(base2)

fwrite(base3, "export_shiny.csv")

