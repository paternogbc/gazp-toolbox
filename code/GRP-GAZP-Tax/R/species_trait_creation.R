


# GAZP & GRP Trait matching protocol workflow
# Updated: April 6, 2020
# Updated by : Emma Ladouceur


#### Important Pre-steps !!!!

# Have you been through and completed the 'species_names_processing.R' workflow yet? 

## Have you already performed Git 'pull' from the following repositories?
# gazp-toolbox
# GAZP_Database
# GRP_ Database

# Yes? Then continue your adventure :)


# load libraries needed
library(tidyverse)
library(openxlsx)
library(stdnames) 

# load functions needed
source("./grp_species_input_functions.R")


### Step 1: Bring in ist of new species produced in "species_names_processing.R"

# DB_##_new_t.csv
#new_sps <- read.csv(file.choose())

#
ext <- "./data-sets/example/" # change the last folder name for every new dataset
new_sps <- read.csv(paste(ext, "GRP_19_new_t.csv", sep = "")) 



head(new_sps)

# Flag infraspecies
new_sps <- new_sps %>%
  separate(name, into = c("genus", "species", 
                          "type", "infra_name"),
           remove = FALSE)

head(new_sps, n=10)


# List of (GAZP) known synonyms
# make sure this is the most recently updated version of the species_names_list (ie that you just updated with this species list)
# or else it wont work.
# Emma's path
gazp <- read.xlsx("~/Desktop/Academic/R code/GAZP_Database/species_names_list_t.xlsx")
# Nancy's path

# Clara's path

# Gustavo's path


head(gazp)

# Trait data
form <- read.csv("./data-sets/try/try_lifeform.csv")
span <- read.csv("./data-sets/try/try_lifespan.csv")
nfix <- read.csv("./data-sets/try/try_nfix.csv")
wood <- read.csv("./data-sets/try/try_woodiness.csv")
photo <- read.csv("./data-sets/try/try_photosynthesis.csv")
seed <- read.csv("./data-sets/try/sid_correction.csv")

# GAZP Database species file as template
# Emma's path
gazp_traits <- read.xlsx("~/Desktop/Academic/R code/GAZP_Database/species_long_traits.xlsx")

# Nancy's path

# Clara's path

# Gustavo's path

new_traits <- gazp_traits %>%
  filter(is.na(speciesid))

# This is a blank sheet, but with the right columns we are about to fill in
new_traits


#### Step 2: Build up data frame for each species
for(i in 1:nrow(new_sps)) {
  
  print(new_sps$name[i])
  
  # Make room in the new frame
  new_traits <- new_traits %>%
    add_row()
  
  # Get higher taxonomic information
  taxo <- std_names(data.frame(name = new_sps$name[i]), 
                      species_column = "name")$corrected_list
  
  # Get all potential synonyms
  names_list <- data.frame(name = 
                             gazp$name[gazp$speciesid ==
                                         new_sps$speciesid[i]])
  names_list <- names_list %>%
    separate(name, into = c("genus", "species", 
                            "type", "infra_name"),
             remove = FALSE)
  
  # Compile taxonomy
  new_traits$speciesid[i]  <- 
    as.character(new_sps$speciesid[i])
  new_traits$group[i]      <- taxo$group
  new_traits$order[i]      <- taxo$order
  new_traits$family[i]     <- taxo$family
  new_traits$genus[i]      <- new_sps$genus[i]
  new_traits$species[i]    <- new_sps$species[i]
  new_traits$sub_type[i]   <- new_sps$type[i]
  new_traits$name[i]       <- new_sps$infra_name[i]
  new_traits$lifeform[i]   <- "FILL ME IN" # this is subjective
  new_traits$seedmass[i]   <- seed_mass(names_list, seed)
  new_traits$path[i]       <- 
    as.character(photosynthesis(names_list, photo))
  new_traits$raunkiaer[i]  <- 
    as.character(raunk(names_list, form))
  new_traits$woodiness[i]  <- 
    as.character(woodiness(names_list, wood))
  new_traits$nfix[i]       <- 
    as.character(n_fixing(names_list, nfix))
  new_traits$lifespan[i]   <- 
    as.character(span_group(names_list, span))
  
}

head(new_traits, n= 30)

nrow(new_traits)


### Step 3: file outputs

## Output 1:  unique list for the study being worked on
#### Point to new data set location

# ##_new_traits.csv
# write.csv(new_traits, paste(ext, "GRP_19_new_traits.csv",
#                               sep = ""), row.names = FALSE)


# test write
ext <- "./data-sets/example/" # change the last folder name for every new dataset
write.csv(new_traits, paste(ext, "GRP_19_new_traits.csv",
                              sep = ""), row.names = FALSE)


## Output 2: the new species_long_traits.xlsx list
# bind the new rows with existing gazp species_long_traits.xlsx

new_list<- gazp_traits %>% bind_rows(new_traits) %>%
  arrange(speciesid)

# any duplicates? sanity check
dup.traits<- new_list %>% group_by(speciesid) %>% filter(n()>1) %>% summarize(n=n()) %>%
  select(speciesid,n)

dup.traits

nrow(gazp_traits)
nrow(new_list)

# Test write
ext <- "./data-sets/example/" # change the last folder name for every new dataset
write.xlsx(new_list, paste(ext, "species_long_traits.xlsx",
                            sep = ""), row.names = FALSE)



# We will write this back to the GAZP_Database as a version controlled record
# write.xlsx(new_list, "~/Desktop/Academic/R code/GAZP_Database/species_long_traits.xlsx",
#            sep = "", row.names = FALSE)

# AND to the GRP_Database as a version controlled record
# write.xlsx(new_list, "~/Desktop/Academic/R code/GRP_Database/species_long_traits.xlsx",
#            sep = "", row.names = FALSE)


#### Important Closing-Steps !!!!!
##  1. Any important updates?
#     - update the update info notes at the top of the code
#     - update the README.md file in this repository (if needed / applicable)
#     - let the group know any updates or problems in 'taxonomic protocol' channel in the Slack group

## 2. Git 'commit' and 'push' :

#  - Give an informative commit name

# Git push for all 3 following repositories:
# gazp-toolbox # informative commit name based on any updates
# GAZP_Database # give a commit name for the study that was added eg. GRP 19
# GRP_ Database # give a commit name for the study that was added eg. GRP 19

