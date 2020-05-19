# Frontmatter ####
#
# Loading the libraries
library(tidyverse)
library(purrr)
library(digest)
library(here)
library(broom)

# Load the data using the here function
# This uses the readr package (read_csv is part of that)
# read_csv IS a data.frame but it's a tibble
# you can also use names(df) to get the names of the columns - this is base R
bookings <- read_csv(here("data", "bookings.csv"))
properties <- read_csv(here("data", "properties.csv"))

# So the grand challenge:
# For each city, fit a linear model (lm) to predict properties' average review score
# with average price per night, number of bookings (stayed OR cancelled)
# and property type. Then compare the predictive power (R-squared)
# across the cities. Also remove properties with less than 2 non-missing
# review scores.
#
# That's a lot, huh?
propertydata <- bookings %>% 
  left_join(properties) %>% 
  group_by(destination, property_id, property_type) %>% 
  filter(sum(!is.na(review_score)) > 1) %>% 
  summarise(
    avg_review = mean(review_score, na.rm = TRUE),
    n_bookings = n(),
    avg_price  = mean(price_per_night))

# now we fit the regression model
city_models <- propertydata %>% 
  group_by(destination) %>% 
  summarise(fit = list(lm(avg_review ~ # give us a regression model for review predicted by...
                            property_type +
                            n_bookings +
                            avg_price)))

# and we get our R^2
city_r2 <- city_models %>% 
  mutate(rsq = map_dbl(fit, ~ summary(.)$r.squared))

city_r2

# and plot 'em
city_r2 %>% 
  ggplot(aes(destination, rsq)) +
  geom_col()

# You can do similar stuff with broom and it actually looks a bit better

city_models %>% 
  mutate(fit_summary = map(fit, glance)) %>% #glance gives you the summary statistics
  unnest(fit_summary)
