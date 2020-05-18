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

# purrr ####
#
# functional programming
# this is basically a way to repeat yourself elegantly
# 
# digest()
# we want to hash the property_id
# how would you do it for every property?
digest(123) # example of what it does

# digest() is not vectorized, it gives a hash for an entire object
# this is the bad way to write a 'for' loop to make this work
hashes <- c()
for (id in properties$property_id) {
  hashes <- c(hashes, digest(id))
}

# and then use 'hashes' in mutate
hashes

# don't do that.
#
# this is much better
n <- nrow(properties)
hashes <- character(length = n)
for (i in seq_len(n)) {
  hashes[i] <- digest(properties$property_id[i])
}
hashes

# back to purrr
#
# purrr takes care of this stuff for us
# purr's map functions iterate throughe ach element of a vector or list
# applies a function to each element
# returns something for each iteration
# here's a very general way to use it
x <- c(1, 2, 3)
map(x, ~ . + 1) # this is an anonymous function, the . just refers to the thing itself, so x in this case

map(x, ~ digest(.)) # now you get a hash for each thing but it gives us back a list

# map() will always return a list.
# map_*() gives you control over what you want back
map_dbl(x, ~ . * 0.5) # gives you back numbers
map_lgl(x, ~ . == 2) # gives you back boolean
map_chr(x, ~ digest(.)) # gives you back character vectors, what we want

# shortcut
map_chr(x, ~ digest(., algo = "sha1")) # this can also be written
map_chr(x, digest, algo="sha1") #like this. it's easier.

# Example ####
# use a map function and digest() to hash encode the property ids
hash_ids <- properties %>% 
  mutate(hash = map_chr(property_id, digest) #if you wanted to replace property_id just replace 'hash' with 'property_id'
hash_ids

