
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

``` r
devtools::install_github("wcornwell/taxonlookup")
devtools::install_github(repo = "paternogbc/gazp-toolbox", subdir = "code/stdnames")
```

## Example

``` r
## basic example code
library(stdnames)

  my_data <- species_data

# Stanardize species names within a comparative dataset
# First check and fix morphotypes
# check morphotypes
mf <- fix_morphotype(x = my_data$species)
#> Names were converted to a character vector
#> Names were converted to `Genus epithet` format instead of `Genus_epithet`
#> 5 species names might be morphotypes! Consider checking `morphotype == yes`
mf[mf$morphotype == "yes", ]
#>              name corrected_name morphotype
#> 4       Elymus NA     Elymus sp.        yes
#> 6      Elymus sp.     Elymus sp.        yes
#> 9      Eucalyptus Eucalyptus sp.        yes
#> 10 Eucalyptus sp. Eucalyptus sp.        yes
#> 17 Heracleum spp.  Heracleum sp.        yes

# Replace morphotype names
my_data$species <- mf$corrected_name

# Run protocol to standardize plant names (trai_columns indicate columns you want to keep)
out <- std_names(x = my_data, species_column = "species", trait_columns = "var_num")
#> Be aware, duplicated names were provied on the  ` species ` column!
#> Warning in TPLck(sp = d, infra = infra, corr = corr, diffchar = diffchar, :
#> The specific epithet of Eucalyptus sp. could not be matched, and multiple
#> corrections are possible.

#> Warning in TPLck(sp = d, infra = infra, corr = corr, diffchar = diffchar, :
#> The specific epithet of Eucalyptus sp. could not be matched, and multiple
#> corrections are possible.
#> 5 name (s) submitted were not found in The Plant List!
#> 2 names submitted were corrected automatically! Make sure they are right.
#> 5 duplicated name (s) were detected

# Clean list of corrected names
out$corrected_list
#>               original_name                 tpl_name    tpl_genus
#> 1       Acacia acanthoclada      Acacia acanthoclada       Acacia
#> 2       Acacia acanthoclada      Acacia acanthoclada       Acacia
#> 3    Echinacea angustifolia   Echinacea angustifolia    Echinacea
#> 4                Elymus sp.                                Elymus
#> 5       Elymus trachycaulus      Elymus trachycaulus       Elymus
#> 6                Elymus sp.                                Elymus
#> 7  Eschscholzia californica Eschscholzia californica Eschscholzia
#> 8       Eucalyptus annulati      Eucalyptus annulata   Eucalyptus
#> 9            Eucalyptus sp.                            Eucalyptus
#> 10           Eucalyptus sp.                            Eucalyptus
#> 11     Eucalyptus lehmannii     Eucalyptus lehmannii   Eucalyptus
#> 12     Festuca occidentalia     Festuca occidentalis      Festuca
#> 13   Gastrolobium racemosum   Gastrolobium racemosum Gastrolobium
#> 14        Geranium pratense        Geranium pratense     Geranium
#> 15          Goodenia azurea          Goodenia azurea     Goodenia
#> 16       Hakea pandanicarpa       Hakea pandanicarpa        Hakea
#> 17            Heracleum sp.                             Heracleum
#> 18         Knautia arvensis         Knautia arvensis      Knautia
#> 19             Yucca glauca             Yucca glauca        Yucca
#>     tpl_epithet tpl_infra_rank tpl_infra_name         family        order
#> 1  acanthoclada                                     Fabaceae      Fabales
#> 2  acanthoclada                                     Fabaceae      Fabales
#> 3  angustifolia                                   Asteraceae    Asterales
#> 4                                                    Poaceae       Poales
#> 5  trachycaulus                                      Poaceae       Poales
#> 6                                                    Poaceae       Poales
#> 7   californica                                 Papaveraceae Ranunculales
#> 8      annulata                                    Myrtaceae     Myrtales
#> 9                                                  Myrtaceae     Myrtales
#> 10                                                 Myrtaceae     Myrtales
#> 11    lehmannii                                    Myrtaceae     Myrtales
#> 12 occidentalis                                      Poaceae       Poales
#> 13    racemosum                                     Fabaceae      Fabales
#> 14     pratense                                  Geraniaceae   Geraniales
#> 15       azurea                                 Goodeniaceae    Asterales
#> 16 pandanicarpa                                   Proteaceae    Proteales
#> 17                                                  Apiaceae      Apiales
#> 18     arvensis                               Caprifoliaceae   Dipsacales
#> 19       glauca                                 Asparagaceae  Asparagales
#>          group on_tpl fail_rank changed     var_num
#> 1  Angiosperms   TRUE     FALSE   FALSE  0.07359603
#> 2  Angiosperms   TRUE     FALSE   FALSE -0.90278937
#> 3  Angiosperms   TRUE     FALSE   FALSE  0.68197697
#> 4  Angiosperms  FALSE     FALSE   FALSE  0.46072188
#> 5  Angiosperms   TRUE     FALSE   FALSE  0.52959355
#> 6  Angiosperms  FALSE     FALSE   FALSE  0.54760644
#> 7  Angiosperms   TRUE     FALSE   FALSE  0.99663048
#> 8  Angiosperms   TRUE     FALSE    TRUE -0.81900454
#> 9  Angiosperms  FALSE     FALSE   FALSE  1.60352719
#> 10 Angiosperms  FALSE     FALSE   FALSE -0.02320222
#> 11 Angiosperms   TRUE     FALSE   FALSE  0.66608011
#> 12 Angiosperms   TRUE     FALSE    TRUE -0.50078908
#> 13 Angiosperms   TRUE     FALSE   FALSE  0.98384328
#> 14 Angiosperms   TRUE     FALSE   FALSE -1.54237259
#> 15 Angiosperms   TRUE     FALSE   FALSE  0.80121890
#> 16 Angiosperms   TRUE     FALSE   FALSE -1.06696758
#> 17 Angiosperms  FALSE     FALSE   FALSE  0.23201906
#> 18 Angiosperms   TRUE     FALSE   FALSE  3.01732128
#> 19 Angiosperms   TRUE     FALSE   FALSE  1.96812967

# List of unmacthed names
out$unmatched_list
#>     original_name tpl_name  tpl_genus tpl_epithet tpl_infra_rank
#> 4      Elymus sp.              Elymus                           
#> 6      Elymus sp.              Elymus                           
#> 9  Eucalyptus sp.          Eucalyptus                           
#> 10 Eucalyptus sp.          Eucalyptus                           
#> 17  Heracleum sp.           Heracleum                           
#>    tpl_infra_name    family    order       group on_tpl fail_rank changed
#> 4                   Poaceae   Poales Angiosperms  FALSE     FALSE   FALSE
#> 6                   Poaceae   Poales Angiosperms  FALSE     FALSE   FALSE
#> 9                 Myrtaceae Myrtales Angiosperms  FALSE     FALSE   FALSE
#> 10                Myrtaceae Myrtales Angiosperms  FALSE     FALSE   FALSE
#> 17                 Apiaceae  Apiales Angiosperms  FALSE     FALSE   FALSE
#>        var_num
#> 4   0.46072188
#> 6   0.54760644
#> 9   1.60352719
#> 10 -0.02320222
#> 17  0.23201906

# For detailed output (see out$detailed_output)
# e.g. which species were corrected automatically?
out$detailed_output$which_corrected
#>         submitted_name       corrected_name
#> 1  Eucalyptus annulati  Eucalyptus annulata
#> 2 Festuca occidentalia Festuca occidentalis

# e.g. which species failed?
out$detailed_output$which_fail_name
#> [1] "Elymus sp."     "Elymus sp."     "Eucalyptus sp." "Eucalyptus sp."
#> [5] "Heracleum sp."
```
