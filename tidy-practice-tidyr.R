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

# Full join the datasets into 'd'
d <- bookings %>% full_join(properties)

# Handling missing values ####
#
# drop_na
#
# this drops every row with a missing value in ANY column
d %>% drop_na() # it gets rid of about 4000 columns in this case

# use it this way, instead
d %>% drop_na(review_score) # this just drops rows with a missing review_score


# reshaping data ####
#
# quick data munge
#
day_order <- c("sun", "mon", "tue", "wed", "thu", "fri", "sat")

checkin_count <- d %>% 
  count(destination, checkin_day) %>% 
  mutate(checkin_day = factor(checkin_day, levels = day_order))
checkin_count

# but if you want a table that has the destination as a single row
# and each day as a column
# and the count for each as values
# gather() and spread()
# this uses spread()
wide_checkin_count <- checkin_count %>% 
  spread(checkin_day, n)

wide_checkin_count

# but what if you want to go back?
# gather()
wide_checkin_count %>% 
  gather(day, n, sun, mon, tue, wed, thu, fri, sat) # first is key, n is count, then list the columns you want to collapse into those two

# challenge ####
#
# For each property, calculate the average review score given by business bookers and tourists.
# Plot these against each other in a scatterplot
# this doesn't have to be in a single pipeline
# remember we're using the d df
review_by_type <- d %>%
  group_by(property_id, for_business) %>% 
  summarise(review_score = mean(review_score, na.rm = TRUE))
review_by_type

# spread into columns to plot against eachother
# the mutate line renames TRUE and FALSE "for_business" to useful names
# uses the if_else dplyr function
wide_reviews <- review_by_type %>% 
  mutate(for_business = if_else(for_business, "business", "tourist")) %>% 
  spread(for_business, review_score)

# create the plot
# this is why you need the two columns
# so why you had to spread it out
wide_reviews %>% 
  ggplot(aes(tourist, business)) +
    geom_point()

