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