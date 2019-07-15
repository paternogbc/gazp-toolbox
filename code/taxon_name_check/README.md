# taxon_name_check

R functions to standardize GAZP species names following a reproducible protocol.

*** 

## Details



### Files

| file | type | description |  
| :---: | :---: | :--- |  
| [utils.R](R/utils.R) | R functions | Simple functions to perform basic/repetitive tasks |
| [protocol_functions.R](R/protocol_functions.R) | R functions | Functions to perform species name standardization |


### Functions

| name | description |  
| :---: | :---: |  
| `basic_check()` | Check if provided list is a character vector, if style is "Genus epithet". |
| `parse_name()` | Parse names (split Genus, epithet) on species list! |
| `morpho_check()` | Find potential morphotypes and typos in the species list |
| `tpl_genus()` | Download an updated list of all Genus names from The Plant List |
| `tpl_genus_search()` | function to check if a genus exist and get its species list from The Plant List website. |
| `higher_tax()` | Function to prepare higher taxonomic table from a species list and find Genus that do not belong to the TPL list v1.1 |
