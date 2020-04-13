# Taxonomic Protocol

Functions and code to process species names for GAZP & GRP.

*** 

## Details

![](static/dichanthium.jpg)

Taxonomic protocol workflow to process species names and match to trait values

### Files

| file | type | description |  
| :---: | :---: | :--- |  
| [species_input_functions.R](R/species_input_functions.R) | R functions | code_creation and all functions for traits processing |  
| [species_names_processing.R](R/species_names_processing.R) | Workflow | Taxonomic protocol that speaks to input functions |  
| [species_trait_creation.R](R/species_trait_creation.R) | Workflow | Trait matching protocol that speaks to input functions |  
| [seeded_species.R](R/seeded_species.R) | Workflow | Takes unique speciesid from seeded species list and matches to master species list to produce a 'seeded species' list |  


## Usage

> If you are updating the official species list, make sure to Pull from the GAZP_Database Github Repository before beginning. Follow the 'Important Pre-Steps' at the beginning of 'species_names_processing.R' and closing steps at the end of 'species_trait_creation.R' 

This workflow should be used to process the species list from every study seperately. Working directories should be changed to match each appropriate working directory. 

The Taxonomic protocol will highlight conflicts in species names and summarise them in a table in Step 6, towards ther end of the workflow. The conflicetd species names need to be changed manually. Code is provided so that corrections can just filled into the code. Instead of deleteing this lines when not relevant , just use a '#' at the beginning of the line of code to comment that line out, but maintain the lines of code for future use.

The trait matching protocol will record multiple records where they exist. This should be corrected manually after. 

Wherever a file path needs to be manually changed, please just copy the path link, correct to your own path with a label and list in below the others so they do not have to be rewritten every time. 

If you feel additional notes are needed somewhere, please feel encouraged to add to these, or post in the *'taxonomic protocol'* Channel of the Slack group to request a better explanation

## Database Outputs

The outputs here are collaborative species lists between GAZP & GRP. Using this workflow helps us to seamlessly and collaboratively update these parts of the database, to make the two efforts speak to each other flawlessly.

| file | location | description |  
| :---: | :---: | :--- |  
| species_names_list.xlsx| GAZP_Database Repository | Master Species List : including all known synonyms |  
| species_long_traits.xlsx | GAZP_Database Respository | A longform species list: including accepted species names only, all associated higher taxonomic information & traits data |  
| seeded_species.xlsx | GAZP_Database Respository | A list of species seeded within GAZP (& eventually GRP), to seperate these species from vegetation community data | 

## Room for Improvement / To-Do List

Possibilities to write functions to process the multiple options of Raunkiaer traits, photosynthetic path, or to automatically fill in possibilities for life forms possible, based on sets of rules, but not yet implemented.

The seeded_species.R code does not match perfectly with the master species list, and work can be done to fix this, but it has been left as-is for now. This file has not yet been created as a result.

Testing writing outputs directly to GAZP_Database and GRP_Database files with a consistent link to each file path in R (as opposed to our unique file paths). Think this cannot be done easily for private repositories though?


## Updates Log

| date | name | description |  
| :---: | :---: | :--- |  
| April 6, 2020 | Emma Ladouceur | A large update. **Taxonomic workflow:**  morphospecies automatic code creation, the identification of conflicts within new species & synonyms, synonym & accepted name tracking and reporting, conflict summary reports, and pre-written code to manually change speciesid and provide a quicker workflow. **Traits workflow:** the inclusion of multiple values for raunkiaer and life forms traits. This includes changes to functions in *species_input_functions.R* for both code_creation and traits processing.

