# Frontmatter ####
#
# Loading the libraries
library(tidyverse)
library(here)

# Load the data using the here function
# This uses the readr package (read_csv is part of that)
# read_csv IS a data.frame but it's a tibble
# you can also use names(df) to get the names of the columns - this is base R
bookings <- read_csv(here("data", "bookings.csv"))
properties <- read_csv(here("data", "properties.csv"))

# dplyr ####
#
# This is all about dplyr()
# Cheatsheet available at https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf
#
# mutate()
#
# creating a new column if it doesn't exist or replace one that does
bookings %>% 
  mutate(total_price = price_per_night * room_nights)

# or replace an existing column
bookings %>% 
  mutate(property_id = as.factor(property_id))

# Example 1 ####
#
# create a new column that's the mean-cenetered price_per_night
# mean center: x - mean(x)
bookings %>% 
  mutate(centered_ppn = price_per_night - mean(price_per_night))

# summarise()
#
# takes a bunch of rows and returns one
# note that it's still a data.frame of 1x1
bookings %>% 
  summarise(review_score = mean(review_score, na.rm = TRUE))

# another example
# this gives you the number of values and then the number of missing items as n_miss
bookings %>% 
  summarise(
    n = n(),
    n_miss = sum(is.na(review_score)),
    review_score = mean(review_score, na.rm = TRUE)
  )

# Example 2
#
# one-row summary with number of rows, number of stayed bookings, and mean of total price
bookings %>% 
  mutate(total_price = price_per_night * room_nights) %>% 
  summarise(
    n          = n(),
    n_stayed   = sum(status == "stayed"),
    mean_price = mean(total_price)
  )

# group_by()
#
# takes dataframe and under the hood partitions things out separately when you do more
# group by "for business" folks
# you won't see much unless you view it and you'll see "Groups:  for_business [2]"
by_type <- bookings %>% 
  group_by(for_business)
class(by_type)

# summarize per group
bookings %>% 
  group_by(for_business) %>% 
  summarise(
    n = n(),
    review_mean = mean(review_score, na.rm = TRUE)
  )

# now the centered mean
bookings %>% 
  group_by(for_business) %>% 
  mutate(centered_review = review_score - mean(review_score, na.rm = TRUE))
  
# You can get multiple groups. This seems really powerful
# example, get the mean review score for people traveling on business
# or not and by check_in day
bookings %>% 
  group_by(for_business, checkin_day) %>% 
  summarise(mean_review = mean(review_score, na.rm = TRUE))

# count()
#
# this is a nice little shortcut for just getting counts for things
bookings %>% 
  count(for_business, status)

# *_join tables
#
# very SQL, it combines data
bookings %>% 
  left_join(properties, by = "property_id")
