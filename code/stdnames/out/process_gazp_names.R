# Load packages -----------------------------------------------------------
library(stdnames)
library(dplyr)


# Load data ---------------------------------------------------------------
d <- read.csv("data-raw/gazp_species_list.csv", stringsAsFactors = F)

# Find and Fix Morphotypes ------------------------------------------------
mt <- fix_morphotype(x = d$name_submitted)

# check if fix were ok
mt %>% filter(morphotype == "yes")

# Add fixed names to the original dataset
d$name_submitted <- mt$corrected_binomial

# Standardize names
std_gazp <- std_names(x = d[sample(1:500, size = 25),],
                      species_column = "name_submitted", id_label = "gazp")

