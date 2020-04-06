

# GAZP & GRP Taxonomic protocol workflow
# Updated: April 6, 2020
# Updated by : Emma Ladouceur


#### Important Pre-steps !!!!!
## Git 'pull' from the following repositories:
#  - gazp-toolbox
#  - GAZP_Database
#  - GRP_Database (don't need to for testing)


# install packages if needed
# devtools::install_github("wcornwell/taxonlookup")
# devtools::install_github(repo = "paternogbc/gazp-toolbox", subdir = "code/stdnames")

# load libraries needed
library(tidyverse)
library(openxlsx)
library(tidyverse)
library(stdnames) 
library(taxonlookup)

getwd()
# load functions required
source("./code/GRP-GAZP-Tax/R/species_input_functions.R")

#### Bring in GAZP and new species lists
# Emma's path
gazp <- read.xlsx("~/Desktop/Academic/R code/GAZP_Database/species_names_list.xlsx")
# Nancy's path

# Clara's path

# Gustavo's path

#### Point to new data set location
ext <- "./data-sets/example/" # change the last folder name for every new dataset
in_sp <- read.xlsx(paste(ext, "GRP_19_species.xlsx", sep = "")) 

## Clean white spaces
in_sp$name <- white_space(in_sp$name)

#### Step 1: See how many species match between the database and the new list
in_sp <- in_sp %>%
  left_join(gazp) %>%
  distinct()

head(in_sp)

# Check original data for lifeform groups if applicable
# example you will see alot in America
#in_sp$speciesid[in_sp$name == "Perennial bunch grass"] <- "L_pgrass"


#### Step 2: Apply taxonomic protocol to unmatched names

# a list of species that are new to the database
missing.sp <- in_sp %>%
  filter(is.na(speciesid))

# how many species are missing species codes?
nrow(missing.sp)

### Check and fix for morphotypes
morphs <- fix_morphotype(missing.sp$name, label = "sp.")
# how many morphotypes?
morphs[morphs$morphotype == "yes", ]
# join the morphothypes back with species missing code names
morphs2 <- morphs %>% left_join(missing.sp)

# subset morphotypes
# if none this will just be blank
morphsy <- morphs2 %>%
  filter(morphotype == "yes") %>%
  droplevels() 

# subset non- morphotypes
morphsno <-  morphs2 %>%
  filter(morphotype == "no") %>%
  droplevels() #%>%

# Replace morphotype names with corrected morphotype pattern 
# identify a unique pattern 
# !!!! ( this may be changed depending on dataset) !!!!
pattern <- "sp."
# replace with this
replacement <-  "spp"  
morphsy$corrected_name <- str_replace(morphsy$corrected_name, pattern, replacement)      

## Run GAZP taxonomy protocol using 'std_names'
# !!!!! - takes a few minutes depending on length of unmatched names
out <- std_names(x = morphsno, 
                 species_column = "name", 
                 trait_columns = "Code")

#### Step 3: Check updated names for matches in the existing database
out_prot <- out$corrected_list %>%
  mutate(old_name = original_name,
         name = tpl_name) %>%
  select(Code, old_name, name) %>%
  left_join(gazp)
# label these as non morphotypes again (this column was removed in the protocol)
out_prot$morphotype<- "no"

head(out_prot, n=20)

# change names of morphotypes columns to match non morphotypes
morphsy2 <- morphsy %>%
 mutate(old_name = name,
        name = corrected_name) %>%
 select(-corrected_name)

morphsy2
head(gazp)

# join morphs with gazp, to check for morphotype codes existing in gazp
# If there are no morphotypes this will come up as an error, its fine, keep going forward
morphs_prot <- morphsy2 %>% left_join(gazp, by="name") %>%
  mutate(speciesid =
           ifelse(!is.na(speciesid.x),
                  speciesid.x,
                  speciesid.y)) %>%
  select(Code, old_name, name, speciesid, morphotype)

morphs_prot


# if theres no morphotypes there will be an error , but  its fine to igonore, keep going :)
# bind together the newly corrected morphotypes and the species
out_prot <- bind_rows(out_prot,morphs_prot)


## Match corrected data of missing species to total species list for this study
# if theres no morphotypes you can continue from here
in_sp2 <- in_sp %>%
  left_join(out_prot, by="Code") %>%
  mutate(speciesid =
           ifelse(!is.na(speciesid.x),
                  speciesid.x,
                  speciesid.y),
         old_name = name.x,
         name = name.y) %>%
  select(Code, orig_name,old_name, name, speciesid, morphotype) %>%
 mutate(morphotype = replace_na(morphotype, "no")) %>%
  distinct()

#this is the completer species list for this study back together
nrow(in_sp2)
# but we are still missing some species codes
head(in_sp2)

#### Step 4: Create new species codes
# seperate species with missing codes again into their own list
# if name is unresolved in TPL, 'name column will have an 'NA NA', fill that in with 'old_name'

missings <- in_sp2 %>%
  filter(is.na(speciesid)) %>%
  mutate(name = ifelse(name == "NA NA", old_name, name)) 


head(missings, n= 10)


# create new species code for missing species                            
missings <- code_creation(missings, gazp)
# This will create the appropriate species code Genus + species = Gen_spe , 
# adds a '1' to the end of the species code if it is a subspecies as a default
# Checks if there is a conflict for species codes (and subspecies)
# Marks if there is a conflict or infraspecies needs
# This has to be checked and finalized by hand

# subset morphotypes
morphsonly <- missings %>%
  filter(morphotype == "yes") %>%
  droplevels() %>% arrange(speciesid) %>% select(-old_name)


# subset non morphotypes
nomorphs <-  missings %>%
  filter(morphotype == "no") %>%
  droplevels() %>% arrange(speciesid) 

### Step 5: record and label synonyms

# keep 'old_name' as a synonymn record 
# this will be kept in the gazp master species list as a known synonym for the future
# synonyms get the accepted name species code, but stay in the list as a name record
# and are labelled as a synonym
missings.syn <- nomorphs %>% 
  gather(key="name_cat", value="new_name", old_name:name) %>% # gather 'old_name' and 'name' into same column
arrange(speciesid,name_cat) %>% distinct(Code,new_name,speciesid, infra,morphotype, conflict, .keep_all=TRUE) %>%
  mutate(name_status = fct_recode(name_cat,
                              "synonym" = "old_name",
                              "accepted" = "name")) %>%
  mutate(name= new_name) %>% select(-name_cat, -new_name)

head(missings.syn, n=10) 

# bind these synonyms back together with the morphospecies one last time
missings.c <- missings.syn %>% bind_rows(morphsonly) %>%
  arrange(speciesid)

# filter out only the species and morphospecies with conflicts
conflicted <- missings.c %>% group_by(name) %>%
  filter(conflict =="conflict") 

# categorise speciesid as a factor
conflicted$speciesid<-as.factor(as.character(conflicted$speciesid))
# have a look at the speciesid's with conflicts
# as a simple list
levels(conflicted$speciesid)
# and as a table
conflicted

### Step 6: correct speciesid code conflicts

# create 'conflict.details' data frame
# this table will be your guide to where the conflicts are and where they arise from
conflict.details <- conflicted %>% left_join(gazp, by= "speciesid") %>%
  mutate(gazp_name = name.y,
         conflict_name = name.x,
         shared_id = speciesid) %>%
  select(Code, morphotype, gazp_name,shared_id,conflict_name,name_status) %>%
  arrange(shared_id)

# examine conflict.details
conflict.details

# !!!!!!!!!!!!!!!!!! CHECK MANUALLY !!!!!!!!!!!!
# examine the output from above, and change each conflicted species code below manually


# If 'gazp_name' is NA this means the conflict comes from within the new dataset and is a new species code
# if 'gazp_name' is populated with a name then this means that this species code is already taken within gazp
# 'conflicted_name' is the  species name in the new dataset 
# if a species name is a synonym,  change the species code to the accepted name code

# use this code below to change the conflicts, by changing the species codes and names manually
conflicted.fixed <- conflicted %>% 
  mutate(speciesid = case_when(
    as.character(name) %in% c("Carduus acanthoides") ~ "Car_acanth", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Car_car") ~ "Car_cary", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Fra_vir") ~ "Fra_viri", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Hel_pra") ~ "Helictoch_pra", # duplicate due to similar genus and species name
    as.character(name) %in% c("Hypericum maculatum") ~ "Hyp_macul", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("G_Mal_spp") ~ "G_Malu_spp", # duplicate due to similar genus and species name
    as.character(speciesid) %in% c("Mel_nem") ~ "Mel_nemo", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Res_lut") ~ "Res_lutea", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Sil_vis") ~ "Sil_visca", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Tri_mon") ~ "Tri_mont", # duplicate code, due to similar species names
    as.character(speciesid) %in% c("Ver_off") ~ "Vero_off", # duplicate genus code
    TRUE ~ as.character(speciesid)
  )
  )

# have a look at the outcome
conflicted.fixed
# bind this conflicted fixed list back together with the species that have no conflicts
# this will produce our clean, corrected list of 'new species', their synonyms, and morphospecies to be added to gazp
newsp<- missings.c %>% filter(is.na(conflict)) %>%
  bind_rows(conflicted.fixed) %>%
  arrange(speciesid)

head(newsp)
nrow(newsp)
# remove species id's for next step
m.r<- missings %>% select(Code,old_name, name)

# keep 'old_name' as a synonymn record for each accepted name
newsp.syn <- newsp %>% 
  left_join(m.r) %>% # join with missings to keep other info
  select(Code, old_name, name, speciesid, name_status, infra, morphotype, conflict) %>%
  arrange(speciesid)

# if the species is a synonym record the 'old_name' will be 'NA'
head(newsp.syn)

#### Step 7: Outputs

## Output 1:  A total species list, and species codes from this study only
# we save this list in the study folder , maintaining old names as a record 

in_sp3 <- in_sp2 %>%
  left_join(newsp.syn, by = "Code") %>%
  mutate(speciesid = ifelse(!is.na(speciesid.x),
                            speciesid.x,
                            speciesid.y),
         old_name = old_name.x,
         name = name.x) %>%
  select(Code, orig_name,old_name, name, speciesid) %>%
  distinct(Code, orig_name,old_name, name, speciesid, .keep_all=TRUE)

head(in_sp3,n=10)

## Make sure blank spots in the names column have the old name added in wherever there was no correction necessary
in_sp4 <- in_sp3 %>%
  mutate(name = ifelse(is.na(name), old_name, name)) %>%
  arrange(speciesid)

head(in_sp4, n=10)

# any duplicates?
new.dup.summary <- in_sp4 %>% group_by(Code,orig_name,old_name,name,speciesid) %>% filter(n()>1) %>% summarize(n=n()) %>%
  select(Code,orig_name,old_name,name,speciesid,n)

new.dup.summary

# create our final list of corrected species to be stored in the project folder as a record
in_sp_final <- in_sp4 %>% 
  select(Code, orig_name,old_name, name, speciesid) 


nrow(in_sp) # original new species list
nrow(in_sp_final) # corrected species list
# are these row numbers the same? if not, why not?

# all clean? write the file!
ext <- "./data-sets/example/" # test location
write.csv(in_sp_final, paste(ext, "GRP_19_Processed_species_codes.csv",
                       sep = ""), row.names = FALSE)

# Output 2: New traits
## List of new species only (accepted names only) needing traits and taxonomy
# This file will then be used for gazp_species_trait_creation

new_t <- newsp %>% filter(name_status == "accepted") %>%
  select(name, speciesid) %>%
  distinct()

head(new_t)
nrow(new_t)

# we also write this to the project folder we are currently working on
# this keeps a record of the new species we've queried for traits
write.csv(new_t, paste(ext, "GRP_19_new_t.csv",
                              sep = ""), row.names = FALSE)

# Output 3: an updated master database species list including all new species
## Accepted name, Synonyms and associated new codes for complete taxonomy list

# add  new additional species  including synonyms tto the existing gazp/gazp list and check for duplicates
additional <- newsp.syn %>%
  select(c(name, speciesid)) 

# label these species as new additions
additional$stat <- "new"

nrow(additional)
head(additional)

# label existing species in gazp
gazp$stat <- "existing"

# bind new species and existing list together
new_vers <- gazp %>% bind_rows(additional) %>%
  arrange(speciesid) 

# summarise this list and check for duplicate species names

#c heck for duplicates in gazp
gazp %>% group_by(name) %>% filter(n()>1) %>% summarize(n=n())

# check for new duplicates in 'new_vers'
dup.summary <- new_vers %>% group_by(name) %>% filter(n()>1) %>% summarize(n=n()) %>%
  left_join(new_vers) %>%
  select(speciesid,name,n,stat)

dup.summary

updated_gazp <- new_vers %>% select(speciesid,name) 

nrow(gazp)
nrow(updated_gazp)
head(updated_gazp)


ext <- "./data-sets/example/" # change the last folder name for every new dataset
write.csv(updated_gazp, paste(ext, "species_names_list_example.csv",
                       sep = ""), row.names = FALSE)

# FIRST Lets update it on our Next Cloud so we have the updated record handy
# ****Add a date to the end of this!!!**** ( we are keeping dated records)
# write.xlsx(updated_gazp, "~/Next Cloud/Restore/GRP Data/species_list/species_names_list_04_6_2020.xlsx",
#            sep = "", row.names = FALSE)

# We will write this back to the GAZP_Database as a version controlled record
# write.xlsx(updated_gazp, "~/Desktop/Academic/R code/GAZP_Database/species_names_list_t.xlsx",
#                        sep = "", row.names = FALSE)

# AND to the GRP_Database as a version controlled record
# write.xlsx(updated_gazp, "~/Desktop/Academic/R code/GRP_Database/species_names_list.xlsx",
#            sep = "", row.names = FALSE)


