## code to prepare `species_data` dataset goes here
d <- read.csv("data-raw/example_species_list.csv")

# Create some example variable
species_data <- data.frame(
  species = d$species,
  var_num = rnorm(n = nrow(d)),
  var_cat = sample(x = c("yes", "no"), size = nrow(d), replace = T)
)

usethis::use_data(species_data, overwrite = TRUE)
