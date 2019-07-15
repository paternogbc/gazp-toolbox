# check.packages function: install and load multiple R packages.
# Check to see if packages are installed. Install them if they are not, then load them into the R session.
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# Usage example
packages <- c("ggplot2", "afex", "ez", "Hmisc", "pander", "plyr")
check.packages(packages)

# source R scripts from github
source_github <- function(x){
  script <- RCurl::getURL(x, ssl.verifypeer = FALSE)
  eval(parse(text = script))
}

# Usave example
source_github(x = "https://raw.githubusercontent.com/paternogbc/gazp-toolbox/master/code/template/R/functions.R")

