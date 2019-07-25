# Example on how to run the protocol to standardize plant names from a dataset.

# First install the `stdnames` package from Github
devtools::install_github(repo = "paternogbc/gazp-toolbox", subdir = "stdnames")

# Load packages

library(RCurl)
library(stdnames)

### Get SID weights from Github Repo---
x <- getURL("https://raw.githubusercontent.com/paternogbc/gazp-toolbox/master/data-sets/sid_kew_weights/sid_kew_weights.csv")
d <- read.csv(text = x, stringsAsFactors = F)

### simplify colnames
colnames(d) <- c("genus",  "species", "subspecies", "variant", "weight_g")

### Make variable with a binomial name
d$binomial <- paste(d$genus, d$species)

### Check and fix for morphotypes
# I know this list was already std to "Genus sp.", but if not:
mf <- fix_morphotype(d$binomial, label = "sp.")
mf[mf$morphotype == "yes", ]

### replace names with corrected morphotype pattern
d$binomial <- mf$corrected_binomial
head(d)

### Get a subset of the data at random
set.seed(18765)
ds <- d[sample(x = seq_len(nrow(d)), size = 100), ]
head(ds)

### Run reproducible protocol to standardize plant names
### This will take a while (~ 5 minutes)
out <- std_names(x = ds, species_column = "binomial", id_label = "gazp")

# Your original dataset plus corrected names (tpl_binomial)
# Remove head() for the complete output
head(out$std)

# Only submitted/corrected names
head(out$std_names)

# Complete output (with details on name standardization)
head(out$tpl_all)

# After removing duplicated names
head(out$tpl_clean)

# A higher taxonomy for the clean species list
head(out$taxonomy_clean)

# Names that failed to match the plant list
# In this case all names were included!
out$which_fail

# Names that were automatically corrected
# You must check if this is correct!
out$which_corrected

# Duplicated names after standardization
out$which_duplicated

# The complete output from TPL fuzzy matching
head(out$raw_tpl_out)

# Source data with unique identifiers for each row in the data.frame
head(out$source_data)

### save files
