# Frontmatter ####
#
# Loading the libraries
library(tidyverse)
library(here)
library(magrittr)

# Load the data using the here function
# This uses the readr package (read_csv is part of that)
# read_csv IS a data.frame but it's a tibble
# you can also use names(df) to get the names of the columns - this is base R
bookings <- read_csv(here("data", "bookings.csv"))
properties <- read_csv(here("data", "properties.csv"))

# introducing dplyr ####
# functions are verbs signalling action
# first argument is always a data frame and no quotes required
#
# select()
select(bookings, review_score) # note this doesn't change existing dataframe

# you can just save another object with this, for example
bookings_x <- select(bookings, review_score) # and this is QUICK so you can knock yourself out with this

# You can also just drop a column like so
select(bookings, -booker_id) # and again it doesn't overwrite bookings but it removes the -variable

# filter()
#
# now let's filter() some rows
filter(bookings, status =="stayed") # this just filters the rows using logical operators

# more conditions
filter(bookings, status =="stayed" & is.na(review_score)) # gives everyone that stayed but is missing a review score

# Example 1 ####
# new tibble with room_nights and review_score that's <$80 per night
bookings_lt80 <- filter(bookings, price_per_night <= 80)
bookings_lt80 <- select(bookings_lt80, room_nights, review_score)

# The Pipe ####
#
# Ctrl-Shift-M is the shortcut for it, btw
c(1, 2, 3) %>% sum() 
bookings %>% head(2)

# This is why it's useful:
# Here's how it really works in R
# This is another version of Example 1
head(
  select(
    filter(
      bookings, price_per_night < 80
    ),
    room_nights, review_score
  ),
  2
)
 
# And here's why we use the pipe.
# You can do the same exact thing like this:
bookings %>% 
  filter(price_per_night < 80) %>% 
  select(room_nights, review_score) %>% 
  head(2)

# And if you want to save it to its own object:
bookings_ppn_lt_80 <- bookings %>% 
  filter(price_per_night < 80) %>% 
  select(room_nights, review_score) %>% 
  head(2)

# Essentially, think of the pipe as "and then..."

# Example 2 ####
#
# Testing pipe fitting lol
# Note that this goes IN ORDER of lines
# So if you select out checkin_day first you can't filter by it
# So the order is important!
bookings_wednesday <- bookings %>% 
  filter(checkin_day == "wed") %>% 
  select(property_id, status)

# ggplot2()
#
# Builds plots in layers
# data MUST be a data.frame or tibble
# elements representing data (points, lines, etc) are "geoms"
# Geom appearance (position, color, etc) is defined by aesthetics or "aes"
# layers are added with +
# basic example
ggplot(bookings, aes(x = review_score)) +
  geom_histogram()

# another example using the pipe
bookings %>% 
  ggplot(aes(x = price_per_night, y = review_score)) +
  geom_point()

# Challenge! ####
chal1 <- bookings %>% 
  filter(room_nights >= 7, status == "stayed") %>%  # watch the operators!
  select(price_per_night, review_score) %>% 
  ggplot(aes(x = price_per_night, y = review_score)) +
  geom_point()
chal1
