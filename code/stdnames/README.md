
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stdnames

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/stdnames)](https://cran.r-project.org/package=stdnames)
<!-- badges: end -->

A reproducible protocol to standardize plant names following The Plant
List database.

## Installation (development version)

devtoolss

``` r
devtools::install_github(repo = "paternogbc/gazp-toolbox", subdir = "code/stdnames")
```

## Example

``` r
library(stdnames)
## basic example code
library(stdnames)

my_data <- species_data
# Stanardize species names within a comparative dataset
# First check and fix morphotypes
# check morphotypes
mf <- fix_morphotype(x = my_data$species)
#> 5 species names might be morphotypes! Consider checking `morphotype == yes`
mf[mf$morphotype == "yes", ]
#>    original_binomial corrected_binomial morphotype
#> 4          Elymus NA         Elymus sp.        yes
#> 6         Elymus sp.         Elymus sp.        yes
#> 9         Eucalyptus     Eucalyptus sp.        yes
#> 10    Eucalyptus sp.     Eucalyptus sp.        yes
#> 17    Heracleum spp.      Heracleum sp.        yes

# Replace morphotype names
my_data$species <- mf$corrected_binomial

# Run protocol to standardize plant names
out <- std_names(x = my_data, species_column = "species", id_label = "ID")
#> Be aware, duplicated names were provied on the  ` species ` column!
#> Warning in TPLck(sp = d, infra = infra, corr = corr, diffchar = diffchar, :
#> The specific epithet of Eucalyptus sp. could not be matched, and multiple
#> corrections are possible.

#> Warning in TPLck(sp = d, infra = infra, corr = corr, diffchar = diffchar, :
#> The specific epithet of Eucalyptus sp. could not be matched, and multiple
#> corrections are possible.
#> 5 names submitted are not on The Plant List
#> 2 names submitted were corrected automatically! Make sure they are right.
#> 3 duplicated names (after standardization) were excluded.

# Your original dataset plus corrected names (tpl_binomial)
# Remove head() for the complete output
head(out$std)
#>   id_names                species           tpl_binomial     var_num
#> 1    ID001    Acacia acanthoclada    Acacia acanthoclada  0.07359603
#> 2    ID002    Acacia acanthoclada    Acacia acanthoclada -0.90278937
#> 3    ID003 Echinacea angustifolia Echinacea angustifolia  0.68197697
#> 4    ID004             Elymus sp.             Elymus sp.  0.46072188
#> 5    ID005    Elymus trachycaulus    Elymus trachycaulus  0.52959355
#> 6    ID006             Elymus sp.             Elymus sp.  0.54760644
#>   var_cat
#> 1      no
#> 2      no
#> 3      no
#> 4      no
#> 5     yes
#> 6      no

# Only submitted/corrected names
head(out$std_names)
#>   id_names     submitted_binomial           tpl_binomial
#> 1    ID001    Acacia acanthoclada    Acacia acanthoclada
#> 2    ID002    Acacia acanthoclada    Acacia acanthoclada
#> 3    ID003 Echinacea angustifolia Echinacea angustifolia
#> 4    ID004             Elymus sp.             Elymus sp.
#> 5    ID005    Elymus trachycaulus    Elymus trachycaulus
#> 6    ID006             Elymus sp.             Elymus sp.

# Complete output (with details on name standardization)
head(out$tpl_all)
#>   id_names                species     var_num var_cat
#> 1    ID001    Acacia acanthoclada  0.07359603      no
#> 2    ID002    Acacia acanthoclada -0.90278937      no
#> 3    ID003 Echinacea angustifolia  0.68197697      no
#> 4    ID004             Elymus sp.  0.46072188      no
#> 5    ID005    Elymus trachycaulus  0.52959355     yes
#> 6    ID006             Elymus sp.  0.54760644      no
#>             tpl_binomial            tpl_authority     tpl_id tpl_status
#> 1    Acacia acanthoclada                 F.Muell.  ild-48137   Accepted
#> 2    Acacia acanthoclada                 F.Muell.  ild-48137   Accepted
#> 3 Echinacea angustifolia                      DC. gcc-140068   Accepted
#> 4             Elymus sp.                                               
#> 5    Elymus trachycaulus (Link) Gould ex Shinners kew-411630   Accepted
#> 6             Elymus sp.                                               
#>   tpl_version on_tpl corrected misapplied duplicated
#> 1         1.1   TRUE     FALSE      FALSE      FALSE
#> 2         1.1   TRUE     FALSE      FALSE       TRUE
#> 3         1.1   TRUE     FALSE      FALSE      FALSE
#> 4         1.1  FALSE     FALSE      FALSE      FALSE
#> 5         1.1   TRUE     FALSE      FALSE      FALSE
#> 6         1.1  FALSE     FALSE      FALSE       TRUE

# After removing duplicated names
head(out$tpl_clean)
#>   id_names                  species     var_num var_cat
#> 1    ID001      Acacia acanthoclada  0.07359603      no
#> 2    ID003   Echinacea angustifolia  0.68197697      no
#> 3    ID004               Elymus sp.  0.46072188      no
#> 4    ID005      Elymus trachycaulus  0.52959355     yes
#> 5    ID007 Eschscholzia californica  0.99663048      no
#> 6    ID008      Eucalyptus annulati -0.81900454      no
#>               tpl_binomial            tpl_authority      tpl_id tpl_status
#> 1      Acacia acanthoclada                 F.Muell.   ild-48137   Accepted
#> 2   Echinacea angustifolia                      DC.  gcc-140068   Accepted
#> 3               Elymus sp.                                                
#> 4      Elymus trachycaulus (Link) Gould ex Shinners  kew-411630   Accepted
#> 5 Eschscholzia californica                    Cham. kew-2801972   Accepted
#> 6      Eucalyptus annulata                   Benth.   kew-72446   Accepted
#>   tpl_version on_tpl corrected misapplied duplicated
#> 1         1.1   TRUE     FALSE      FALSE      FALSE
#> 2         1.1   TRUE     FALSE      FALSE      FALSE
#> 3         1.1  FALSE     FALSE      FALSE      FALSE
#> 4         1.1   TRUE     FALSE      FALSE      FALSE
#> 5         1.1   TRUE     FALSE      FALSE      FALSE
#> 6         1.1   TRUE      TRUE      FALSE      FALSE

# A higher taxonomy for the clean species list
head(out$taxonomy_clean)
#>   id_names        original_binomial        genus       family        order
#> 1    ID001      Acacia acanthoclada       Acacia     Fabaceae      Fabales
#> 2    ID003   Echinacea angustifolia    Echinacea   Asteraceae    Asterales
#> 3    ID004               Elymus sp.       Elymus      Poaceae       Poales
#> 4    ID005      Elymus trachycaulus       Elymus      Poaceae       Poales
#> 5    ID007 Eschscholzia californica Eschscholzia Papaveraceae Ranunculales
#> 6    ID008      Eucalyptus annulata   Eucalyptus    Myrtaceae     Myrtales
#>         group on_tpl
#> 1 Angiosperms   TRUE
#> 2 Angiosperms   TRUE
#> 3 Angiosperms   TRUE
#> 4 Angiosperms   TRUE
#> 5 Angiosperms   TRUE
#> 6 Angiosperms   TRUE

# Names that failed to match the plant list
# In this case all names were included!
out$which_fail
#> [1] "Elymus sp."     "Elymus sp."     "Eucalyptus sp." "Eucalyptus sp."
#> [5] "Heracleum sp."

# Names that were automatically corrected
# You must check if this is correct!
out$which_corrected
#>   id_names       submitted_name       corrected_name
#> 1    ID008  Eucalyptus annulati  Eucalyptus annulata
#> 2    ID012 Festuca occidentalia Festuca occidentalis

# Duplicated names after standardization
out$which_duplicated
#>    id_names  submitted_binomial        tpl_binomial
#> 1     ID001 Acacia acanthoclada Acacia acanthoclada
#> 2     ID002 Acacia acanthoclada Acacia acanthoclada
#> 4     ID004          Elymus sp.          Elymus sp.
#> 6     ID006          Elymus sp.          Elymus sp.
#> 9     ID009      Eucalyptus sp.      Eucalyptus sp.
#> 10    ID010      Eucalyptus sp.      Eucalyptus sp.

# The complete output from TPL fuzzy matching
head(out$raw_tpl_out)
#>   id_names                species     var_num var_cat
#> 1    ID001    Acacia acanthoclada  0.07359603      no
#> 2    ID002    Acacia acanthoclada -0.90278937      no
#> 3    ID003 Echinacea angustifolia  0.68197697      no
#> 4    ID004             Elymus sp.  0.46072188      no
#> 5    ID005    Elymus trachycaulus  0.52959355     yes
#> 6    ID006             Elymus sp.  0.54760644      no
#>                    Taxon     Genus Hybrid.marker Abbrev Infraspecific.rank
#> 1    Acacia acanthoclada    Acacia                 <NA>               <NA>
#> 2    Acacia acanthoclada    Acacia                 <NA>               <NA>
#> 3 Echinacea angustifolia Echinacea                 <NA>               <NA>
#> 4             Elymus sp.    Elymus                 <NA>               <NA>
#> 5    Elymus trachycaulus    Elymus                 <NA>               <NA>
#> 6             Elymus sp.    Elymus                 <NA>               <NA>
#>   Infraspecific Authority         ID Plant.Name.Index TPL.version
#> 1                          ild-48137             TRUE         1.1
#> 2                          ild-48137             TRUE         1.1
#> 3                         gcc-140068             TRUE         1.1
#> 4                                               FALSE         1.1
#> 5                         kew-411630             TRUE         1.1
#> 6                                               FALSE         1.1
#>   Taxonomic.status New.Genus New.Hybrid.marker  New.Species
#> 1         Accepted    Acacia                   acanthoclada
#> 2         Accepted    Acacia                   acanthoclada
#> 3         Accepted Echinacea                   angustifolia
#> 4                     Elymus                            sp.
#> 5         Accepted    Elymus                   trachycaulus
#> 6                     Elymus                            sp.
#>   New.Infraspecific.rank New.Infraspecific            New.Authority
#> 1                                                          F.Muell.
#> 2                                                          F.Muell.
#> 3                                                               DC.
#> 4                   <NA>                                           
#> 5                                          (Link) Gould ex Shinners
#> 6                   <NA>                                           
#>       New.ID New.Taxonomic.status  Typo WFormat Higher.level       Date
#> 1  ild-48137             Accepted FALSE   FALSE         TRUE 2019-07-25
#> 2  ild-48137             Accepted FALSE   FALSE         TRUE 2019-07-25
#> 3 gcc-140068             Accepted FALSE   FALSE         TRUE 2019-07-25
#> 4                                 FALSE   FALSE        FALSE 2019-07-25
#> 5 kew-411630             Accepted FALSE   FALSE         TRUE 2019-07-25
#> 6                                 FALSE   FALSE        FALSE 2019-07-25

# Source data with unique identifiers for each row in the data.frame
head(out$source_data)
#>   id_names                species     var_num var_cat
#> 1    ID001    Acacia acanthoclada  0.07359603      no
#> 2    ID002    Acacia acanthoclada -0.90278937      no
#> 3    ID003 Echinacea angustifolia  0.68197697      no
#> 4    ID004             Elymus sp.  0.46072188      no
#> 5    ID005    Elymus trachycaulus  0.52959355     yes
#> 6    ID006             Elymus sp.  0.54760644      no
```
