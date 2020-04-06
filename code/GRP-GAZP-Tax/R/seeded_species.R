


# Extract the species list of seeded species ( to seperate from veg that is community data)
gazp_seed <- read.xlsx("~/Desktop/Academic/R code/GAZP_Database/projectdata.xlsx", sheet = 9)

gazp_species <- read.xlsx("~/Desktop/Academic/R code/GAZP_Database/species_names_list.xlsx")



seeded <- gazp_seed %>% select(speciesid) %>% distinct(speciesid) %>%
  left_join(gazp_species) %>%
  arrange(speciesid)
  
  

View(gazp_species)
View(seeded)
  