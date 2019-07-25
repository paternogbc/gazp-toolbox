
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
devtools::install_github(repo = "paternogbc/gazp-toolbox", subdir = "stdnames")
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

out$std
#>    id_names                  species             tpl_binomial     var_num
#> 1     ID001      Acacia acanthoclada      Acacia acanthoclada  0.07359603
#> 2     ID002      Acacia acanthoclada      Acacia acanthoclada -0.90278937
#> 3     ID003   Echinacea angustifolia   Echinacea angustifolia  0.68197697
#> 4     ID004               Elymus sp.               Elymus sp.  0.46072188
#> 5     ID005      Elymus trachycaulus      Elymus trachycaulus  0.52959355
#> 6     ID006               Elymus sp.               Elymus sp.  0.54760644
#> 7     ID007 Eschscholzia californica Eschscholzia californica  0.99663048
#> 8     ID008      Eucalyptus annulati      Eucalyptus annulata -0.81900454
#> 9     ID009           Eucalyptus sp.           Eucalyptus sp.  1.60352719
#> 10    ID010           Eucalyptus sp.           Eucalyptus sp. -0.02320222
#> 11    ID011     Eucalyptus lehmannii     Eucalyptus lehmannii  0.66608011
#> 12    ID012     Festuca occidentalia     Festuca occidentalis -0.50078908
#> 13    ID013   Gastrolobium racemosum   Gastrolobium racemosum  0.98384328
#> 14    ID014        Geranium pratense        Geranium pratense -1.54237259
#> 15    ID015          Goodenia azurea          Goodenia azurea  0.80121890
#> 16    ID016       Hakea pandanicarpa       Hakea pandanicarpa -1.06696758
#> 17    ID017            Heracleum sp.            Heracleum sp.  0.23201906
#> 18    ID018         Knautia arvensis         Knautia arvensis  3.01732128
#> 19    ID019             Yucca glauca             Yucca glauca  1.96812967
#>    var_cat
#> 1       no
#> 2       no
#> 3       no
#> 4       no
#> 5      yes
#> 6       no
#> 7       no
#> 8       no
#> 9       no
#> 10     yes
#> 11      no
#> 12     yes
#> 13     yes
#> 14      no
#> 15     yes
#> 16     yes
#> 17     yes
#> 18      no
#> 19     yes
```
