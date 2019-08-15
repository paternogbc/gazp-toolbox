# TRY plant trait data

Files containing species traits, collected from the TRY database 7/17/2019. Each TRY file was cleaned down to trait and species data only. Trait values were then standardized according to rules listed below. Each data set was then put through the GAZP taxonomic standardization protocol. No detailed cleaning post-standardization was conducted. Thus, if an original TRY name was not found in TPL, it was retained with empty values in the TPL-based columns.

*** 

## Details: try_lifeform

There are multiple sources of formal Raunkiaer categories. The GAZP lifeform categories follow Ellenberg and Mueller-Dombois (1967)*. If single TRY entries had multiple values, we standardized to:
: The longer-lived category
: The terrestrial category
: Either the category with the most shoot reduction or (if there were three values), the middle reduction category

### Variables

| variable name | description |  
| :---: | :--- |  
| original | TRY data name, genus and species |
| original_name | if infraspecies designation, infraspecies name |
| final | if found on TPL, TPL output name |
| group | taxonomic based on TPL output either for found species or found genus|
| order | taxonomic based on TPL output either for found species or found genus |
| family | taxonomic based on TPL output either for found species or found genus |
| genus | taxonomic based on TPL output either for found species or found genus |
| species | taxonomic based on TPL output |
| type | infraspecies type, either 'subsp.' or 'var.' based on TPL output |
| name | if infraspecies designation, infraspecies name based on TPL output |
| life | Raukiaer lifeform; values of Hemicryptophyte, Phanerophyte, Chamaephyte, Therophyte, Epiphyte, Geophyte, Helophyte,  Hemiphanaerophyte, Hydrophyte, Liana, Macrophanaerophyte, Nanophanaerophyte, Pseudophanaerophyte, Vascular parasite, Vascular semi-parasite |

*Ellenberg, Heinz and D. Mueller-Dombois. "A key to Raunkiaer plant life forms with revised subdivision." <i>Berlin Geobotanical Institute ETH, Stiftung</i> 37 (1967): 56-73.

*** 

## Details: try_lifeform_names

List of original values for TRY lifeform data and final designation in GAZP toolbox lifeform data.

### Variables
| variable name | description |  
| :---: | :--- |  
| original | TRY data value categories |
| final | final value in GAZP lifeform data |

*** 

## Details: try_lifespan

If single TRY entries had multiple values, all were kept.

### Variables

| variable name | description |  
| :---: | :--- |  
| original | TRY data name, genus and species |
| original_name | if infraspecies designation, infraspecies name |
| final | if found on TPL, TPL output name |
| group | taxonomic based on TPL output either for found species or found genus|
| order | taxonomic based on TPL output either for found species or found genus |
| family | taxonomic based on TPL output either for found species or found genus |
| genus | taxonomic based on TPL output either for found species or found genus |
| species | taxonomic based on TPL output |
| type | infraspecies type, either 'subsp.' or 'var.' based on TPL output |
| name | if infraspecies designation, infraspecies name based on TPL output |
| span |  lifespan of annual, biennial, perennial, or multiple values separated by '/'|

*** 

## Details: try_nfix

TRY data had a variety of values that were standardized to yes or no for the GAZP trait data set.

### Variables

| variable name | description |  
| :---: | :--- |  
| original | TRY data name, genus and species |
| original_name | if infraspecies designation, infraspecies name |
| final | if found on TPL, TPL output name |
| group | taxonomic based on TPL output either for found species or found genus|
| order | taxonomic based on TPL output either for found species or found genus |
| family | taxonomic based on TPL output either for found species or found genus |
| genus | taxonomic based on TPL output either for found species or found genus |
| species | taxonomic based on TPL output |
| type | infraspecies type, either 'subsp.' or 'var.' based on TPL output |
| name | if infraspecies designation, infraspecies name based on TPL output |
| nfix |  binary yes/no of whether species was found to have Nitrogen fixing capability. |

*** 

## Details: try_nfix_names

List of original values for TRY Nitrogen fixing capability data and final designation in GAZP toolbox Nitrogen fixing capability data.

### Variables
| variable name | description |  
| :---: | :--- |  
| original | TRY data value categories |
| final | final value in GAZP Nitrogen fixing capability data (yes or no) |

*** 

## Details: try_photosynthesis

TRY data had multiple versions of each variable that were all standardized. If a species had multiple entries in single cell, cell value designated as "Multi". 

### Variables

| variable name | description |  
| :---: | :--- |  
| original | TRY data name, genus and species |
| original_name | if infraspecies designation, infraspecies name |
| final | if found on TPL, TPL output name |
| group | taxonomic based on TPL output either for found species or found genus|
| order | taxonomic based on TPL output either for found species or found genus |
| family | taxonomic based on TPL output either for found species or found genus |
| genus | taxonomic based on TPL output either for found species or found genus |
| species | taxonomic based on TPL output |
| type | infraspecies type, either 'subsp.' or 'var.' based on TPL output |
| name | if infraspecies designation, infraspecies name based on TPL output |
| photo | photosynthetic pathway of C3, C4, CAM, Multi  |

*** 

## Details: try_photosynthesis_names

List of original values for TRY photosynthetic pathway data and final designation in GAZP toolbox photosynthetic pathway data.

### Variables
| variable name | description |  
| :---: | :--- |  
| original | TRY data value categories |
| final | final value in GAZP photosynthetic pathway data |

*** 

## Details: try_woodiness

TRY data had multiple versions of each variable that were all standardized. If multiple values within single cell, standardized to the most woody value listed.

### Variables

| variable name | description |  
| :---: | :--- |  
| original | TRY data name, genus and species |
| original_name | if infraspecies designation, infraspecies name |
| final | if found on TPL, TPL output name |
| group | taxonomic based on TPL output either for found species or found genus|
| order | taxonomic based on TPL output either for found species or found genus |
| family | taxonomic based on TPL output either for found species or found genus |
| genus | taxonomic based on TPL output either for found species or found genus |
| species | taxonomic based on TPL output |
| type | infraspecies type, either 'subsp.' or 'var.' based on TPL output |
| name | if infraspecies designation, infraspecies name based on TPL output |
| wood | woodiness properties of non-woody, semi-woody, woody  |

*** 

## Details: try_woodiness_names

List of original values for TRY woodiness data and final designation in GAZP toolbox woodiness data.

### Variables
| variable name | description |  
| :---: | :--- |  
| original | TRY data value categories |
| final | final value in GAZP woodiness data |