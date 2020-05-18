# Frontmatter ####
#
# Loading the libraries
library(tidyverse)
library(purrr)
library(digest)
library(here)

# Load the data using the here function
# This uses the readr package (read_csv is part of that)
# read_csv IS a data.frame but it's a tibble
# you can also use names(df) to get the names of the columns - this is base R
bookings <- read_csv(here("data", "bookings.csv"))
properties <- read_csv(here("data", "properties.csv"))
d <- bookings %>% full_join(properties)

# When we can't vectorize our task
#
# List columns
# R dataframes can have a "list" for a column, which are nicely printed by tibbles
properties <- properties %>% 
  mutate(facilities = strsplit(facilities, ",")) #strsplit splits a string with the separator

properties$facilities[1] # this shows you what's in that cell, which is vectorized

# Now 'facilities' is a list column, add a column to 'properties'
# that contains the number of facilities (n_facilities) for each property
properties <- properties %>% 
  mutate(n_facilities = map_int(facilities, length))
properties

# you can also do this
properties %>% 
  mutate(n_facilities = lengths(facilities)) #lenghts does this but NOT 'length'

# listcols
#
# let's do some actual tests
# This won't work:
bookings %>% 
  group_by(checkin_day) %>% 
  summarise(t_test = t.test(review_score ~ for_business))

# why doesn't it work?
# t.tests are lists!
fit <- t.test(hp ~ am, mtcars)
fit
length(fit)
names(fit)

# neat, huh?
# so you get around this by explicitly saying the result should be a list, like so
x <- bookings %>% 
  group_by(checkin_day) %>% 
  summarise(t_test = list(t.test(review_score ~ for_business)))

x$t_test[1]

# let's keep going and create a column for the p value
x <- bookings %>% 
  group_by(checkin_day) %>% 
  summarise(t_test = list(t.test(review_score ~ for_business))) %>% 
  mutate(p_value = map_dbl(t_test, "p.value"))
x
