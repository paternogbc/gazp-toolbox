# SID KEW Seed Weights

Files containing species names and 1000 seed weights from the SID KEW database, collected 7/17/2019.

*** 

## Details: sid_kew_weights

Species names and seed weights taken from the SID KEW database using the sid_kew_scraper python script.

### Variables

| variable name | description |  
| :---: | :--- |  
| Genus | Genus name |
| Species | Species name |
| Subspecies | Subspecies name, if applicable |
| Variant | Variant name, if applicable |
| Seed Weight | 1000 seed weight, in grams |  

*** 

## Details: sid_corrected

Species names and seed weights after GAZP taxonomic correction. Any species not found in TPL has been kept but has no accompanying final taxonomic name. There are duplicate weights for individual species in this file. 

### Variables

| variable name | description |  
| :---: | :--- |  
| original | full name as per the original SID data set |
| original_name | if applicable, infraspecies name, as per the original SID data set |
| final | full name after taxonomic correction, as per TPL findings |
| group | final group name |  
| order | final order name |
| family | final family name |
| genus | final genus name |
| species | final species name |
| type | if applicable, subspecies or variant for infraspecies designation, as per the final TPL classification |
| name | if applicable, infraspecies name, as per the final TPL classification |
| weight | 1000 seed weight, in grams |