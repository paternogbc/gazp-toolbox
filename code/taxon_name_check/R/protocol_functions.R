# Function to perform basic checks on species list!
basic_check <- function(x){
  # number of species
  n <- length(x)
  
  # check if is character
  if (!is.character(x)) {
    x <- as.character(x)
    warning("Species names were converted to character")
  }
  # check if species are not in Genus_epithet format
  if (sum(grepl(pattern = "_", x = x)) != 0) stop(
    "Check if species names are provided in `Genus epithet` format, instead of 
    `Genus_epithet`"
  ) 
  
  message(
    paste(n, 'Species were provided!')
    )
  
  return(x)
}

# Function to parse names (Genus, epithet) on species list!
parse_name <- function(x){
  if (!is.character(x)) {
    stop("x must be a character vector! Run basic_check()")
  }
  n     <- length(x)
  genus <- sapply(strsplit(x, split = " "),FUN = `[`, 1)
  epi   <- sapply(strsplit(x, split = " "),FUN = `[`, 2)
  res   <- data.frame(original_binomial = x,
                      original_genus = genus,
                      original_epi   = epi,
                      stringsAsFactors = FALSE)
  
  ngen  <- length(unique(genus))
                  
  message(paste(
    n, "Species and", 
    ngen, "unique Genus names were provided!"))
  return(res)
}

# Function to find morphotypes in the species list
morpho_check <- function(x, pattern = c("sp.", "spp.", "sp", "spp", "NA", " ")){
  xe  <- x$original_epi
  xb  <- x$original_binomial
  
  wsp    <- lapply(pattern, function(x){
    which(grepl(pattern = x, x = xe, fixed = T))
    })
  names(wsp) <- pattern
  
  
  morp    <- lapply(wsp, function(x) {xb[x]})
  n_morp  <- length(unique(do.call(c, wsp)))
  t_morp  <- sapply(morp, length)
  morp_unique <- unique(do.call(c, wsp))
  x$morphotype <- "no"
  x[morp_unique ,]$morphotype <- "maybe"
  
  if (sum(t_morp) > 0) {
    print(t_morp)
    warning(paste(sum(n_morp), "species names might be morphotypes!"))
    warning("Please check original names provided and `output$morphotypes")
  }
  
  
  out <- list(
    res = x,
    morphotypes = t_morp,
    species     = x[morp_unique, ]$original_binomial
  )
  return(out)
  }

# function to update all genus names from The Plant List
tpl_genus <- function(...){
  cli <- crul::HttpClient$new("http://www.theplantlist.org/1.1/browse/-/-/")
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  out <- xml2::xml_text(xml2::xml_find_all(temp, "//ul[@id='nametree']//a"))
  return(out)
}

# function to check if a genus exist and get its species list from The
# Plant List website.
tpl_genus_search <- function(genus){
  uur <- paste("http://www.theplantlist.org/tpl1.1/search?q=", genus, sep = "")
  cli <- crul::HttpClient$new(uur)
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  all <- xml2::xml_text(xml2::xml_find_all(temp, "//table[@id='tbl-results']//a"))
  
  if (length(all) == 0) {
    message("Genus not found on The Plant List Website")
    out <- list(tpl_genus = paste(genus, "not found on The Plant List"),
                species_list = NULL)
  }
  else {
    all     <- all[seq(1, length(all), 2)]
    genus   <- sapply(strsplit(all, split = " "),FUN = `[`, 1)
    epithet <- sapply(strsplit(all, split = " "),FUN = `[`, 2)
    genus_epithet <- paste(genus, epithet)
    out <- list(tpl_genus = unique(genus),
                species_list = genus_epithet)
    return(out)
  }
}

# Function to prepare higher taxonomy from a species list and find 
# Genus that do not belong to the TPL list.
higher_tax <- function(x) {
  tax <- taxonlookup::lookup_table(
    species_list = x,
    by_species = TRUE,
    missing_action = "NA"
  )
  tax <- 
    tax %>%
    dplyr::rename(original_genus    = genus) %>%
    dplyr::mutate(original_binomial = x,
           genus_on_tpl = !is.na(family) | !is.na(original_genus) | !is.na(order),) %>%
    dplyr::select(original_binomial, original_genus,  dplyr::everything())
  # get unmatched genus
  genus_fail <- tax %>% 
    dplyr::filter(is.na(family) | is.na(original_genus) | is.na(order)) %>%
    dplyr::pull(original_genus)
  
  res <- list(
    taxonomy_full  = tax,
    taxonomy_clean = tax %>% dplyr::filter(genus_on_tpl == TRUE),
    unmatched_genus = genus_fail
  )
  nn <- length(res$unmatched_genus)
  no <- nrow(res$taxonomy_clean)
  if (nn > 0) {
    message(paste("There are", nn, "unmatched genus names!", "\n",
                  "You should probably check these manually!"))
    message(paste(res$unmatched_genus, "\n"))
  } else {
    message(paste(no, "species in the Taxonomic table"))
  }
  
  return(res)
}
