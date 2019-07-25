## code to prepare `species_list` dataset goes here
# Load example species list
species_list <- read.csv("data-raw/example_species_list.csv")

usethis::use_data(species_list, overwrite = TRUE)

