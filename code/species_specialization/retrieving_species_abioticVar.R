#### Call functions for specialization calculations
## This takes a while because it calculates a slope map from a global DEM
source('C:\\Users\\Nancy\\Documents\\GitHub\\gazp-toolbox\\code\\species_specialization\\specialization_functions.R')

#### Get occurrence file
## In the long run, this would be based on new species inputs and drawn from the function gbif_create
# Species names (WITH GAZP CODES)
# Feed into loop that runs gbif_create
# Output gbif results into .csv file
# Run gbif results through two functions
# Track output from functions with GAZP code

## In the short run, it's pulling all of the current species information available
ext <- "D:\\Species files\\"
sps <- list.files(ext)

sps <- data.frame(file = sps) %>%
  separate(file, c("genus", "species"), remove = FALSE)

sps_out <- data.frame(sp = "dummy",
                      variable = "dummy",
                      Range = 0,
                      Mean = 0,
                      SD = 0,
                      Min = 0,
                      Max = 0,
                      N = 0,
                      variable.name = "dummy")

for(i in 50:nrow(sps)) {
  
  occ_list <- read.csv(paste(ext, sps$file[i], sep = ""))
  genus <- sps$genus[i]
  species <- sps$species[i]
  print(paste(genus, species))
  
  sps_out <- sps_out %>%
    bind_rows(occ_clim(occ_list, genus, species)) %>%
    bind_rows(occ_topo(occ_list, genus, species))
  
}
