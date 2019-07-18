# Function to perform basic checks on species list!
basic_check <- function(x, exclude_duplicated = FALSE) {
  # is character?
  if (!is.character(x)) {
    x <- as.character(x)
    warning("Names were converted to a character vector")
  }
  # number of species
  n <- length(x)
  # duplicated names
  dup <- duplicated(x)
  if (!sum(duplicated(x), na.rm = TRUE) == 0) {
    warning("There are duplicated names on the list!")
    message(paste("duplicated species", x[dup], "\n"))
    if (exclude_duplicated == TRUE) {
      warning("Duplicated names were excluded!")
      x <- x[!dup]
    }
  }

  # check if species are not in Genus_epithet format
  if (sum(grepl(pattern = "_", x = x)) != 0) {
    x <- gsub(pattern = "_", replacement = " ", x = x)
    message(
      "Species list was converted to `Genus epithet` format instead of ",
      "`Genus_epithet`"
    )
  }
  message(
    paste(n, "Species were provided!")
  )

  return(x)
}

# Function to parse names (Genus, epithet) on species list!
parse_name <- function(x) {
  if (!is.character(x)) {
    stop("x must be a character vector! Run basic_check()")
  }
  n <- length(x)
  genus <- sapply(strsplit(x, split = " "), FUN = `[`, 1)
  epi <- sapply(strsplit(x, split = " "), FUN = `[`, 2)
  res <- data.frame(
    original_binomial = x,
    original_genus = genus,
    original_epi = epi,
    stringsAsFactors = FALSE
  )
  ngen <- length(unique(genus))
  message(paste(
    n, "Species and",
    ngen, "unique Genus names were provided!"
  ))
  return(res)
}

# Function to find morphotypes in the species list
morpho_check <- function(x, pattern = c("sp.", "spp.", "spp", "NA", " "),
                         correct = FALSE, label = "") {
  # check if names were parsed
  sc <- sum(
    colnames(x) == c(
      "original_binomial", "original_genus", "original_epi"
    )
  )
  if (sc < 3) {
    x <- parse_name(x)
    warning("Names were parsed with 'parse_name()'!!!")
  }

  xe <- x$original_epi
  xb <- x$original_binomial

  # Check if there is true NA in epithet and convert to character
  xe[is.na(xe)] <- "NA"

  wsp <- lapply(pattern, function(x) {
    which(grepl(pattern = x, x = xe, fixed = TRUE))
  })
  names(wsp) <- pattern

  morp <- lapply(wsp, function(x) {
    xb[x]
  })
  n_morp <- length(unique(do.call(c, wsp)))
  t_morp <- sapply(morp, length)
  morp_unique <- unique(do.call(c, wsp))
  x$morphotype <- "no"

  if (sum(t_morp, na.rm = TRUE) > 0) {
    x[morp_unique, ]$morphotype <- "yes"
    warning(paste(sum(n_morp), "species names might be morphotypes!"))
    warning("Please check original names provided and `output$morphotypes")
  }

  if (n_morp == 0) {
    message("No morphotypes were found!")
    correct == FALSE
  }

  if (correct == TRUE) {
    x$corrected_epi <- x$original_epi
    x$corrected_binomial <- x$original_binomial
    x[x$morphotype == "maybe", ]$corrected_epi <- label
    x[x$morphotype == "maybe", ]$corrected_binomial <-
      paste(x[x$morphotype == "maybe", ]$original_genus, label)
  }

  out <- list(
    res = x,
    morphotype = morp,
    species_list = x[morp_unique, ]$original_binomial
  )
  return(out)
}

# function to update all genus names from The Plant List
tpl_genus <- function(...) {
  cli <- crul::HttpClient$new("http://www.theplantlist.org/1.1/browse/-/-/")
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  out <- xml2::xml_text(xml2::xml_find_all(temp, "//ul[@id='nametree']//a"))
  return(out)
}

# function to check if a genus exist and get its species list from The
# Plant List website.
tpl_genus_search <- function(genus) {
  uur <- paste("http://www.theplantlist.org/tpl1.1/search?q=", genus, sep = "")
  cli <- crul::HttpClient$new(uur)
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  all <- xml2::xml_text(xml2::xml_find_all(temp, "//table[@id='tbl-results']//a"))

  if (length(all) == 0) {
    message("Genus not found on The Plant List Website")
    out <- list(
      tpl_genus = paste(genus, "not found on The Plant List"),
      species_list = NULL
    )
  }
  else {
    all <- all[seq(1, length(all), 2)]
    genus <- sapply(strsplit(all, split = " "), FUN = `[`, 1)
    epithet <- sapply(strsplit(all, split = " "), FUN = `[`, 2)
    genus_epithet <- paste(genus, epithet)
    out <- list(
      tpl_genus = unique(genus),
      species_list = genus_epithet
    )
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
    dplyr::rename(submitted_genus = genus) %>%
    dplyr::mutate(
      submitted_binomial = x,
      genus_on_tpl = is.na(family) | is.na(submitted_genus) | is.na(order),
      genus_on_tpl = !genus_on_tpl
    ) %>%
    dplyr::select(submitted_binomial, submitted_genus, dplyr::everything())

  # get unmatched genus
  genus_fail <- tax %>%
    dplyr::filter(is.na(family) | is.na(submitted_genus) | is.na(order)) %>%
    dplyr::pull(submitted_genus) %>%
    unique()

  res <- list(
    taxonomy_full = tax,
    taxonomy_clean = tax %>% dplyr::filter(genus_on_tpl == TRUE),
    unmatched_genus = genus_fail
  )
  nn <- length(res$unmatched_genus)
  if (nn > 0) {
    message(paste(
      "There are", nn, "unmatched genus names!", "\n",
      "You should probably check these manually!"
    ))
    message(paste(res$unmatched_genus, "\n"))
  }
  return(res)
}

clean_tpl <- function(x, verbose = TRUE) {
  ## Check species status
  x$tpl_binomial <- paste(x$New.Genus, x$New.Species)
  fail <- !x$Plant.Name.Index
  n_fail <- sum(fail)
  w_fail <- as.character(x[fail, ]$Taxon)
  miss <- x$Taxonomic.status == "Misapplied"
  n_miss <- sum(miss, na.rm = T)
  w_miss <- as.character(x[miss, ]$Taxon)
  spel <- x$Typo == TRUE
  n_spel <- sum(spel, na.rm = T)
  w_spel <- as.character(x[spel, ]$Taxon)

  xt <-
    data.frame(
      submitted_binomial = x$Taxon,
      submitted_status = x$Taxonomic.status,
      tpl_genus = x$New.Genus,
      tpl_epithet = x$New.Species,
      tpl_binomial = paste(x$New.Genus, x$New.Species),
      tpl_authority = x$New.Authority,
      tpl_id = x$New.ID,
      tpl_status = x$New.Taxonomic.status,
      tpl_version = x$TPL.version,
      on_tpl = x$Plant.Name.Index,
      corrected = spel,
      misapplied = miss
    )

  ### detect and clean dupliacted species
  dup <- duplicated(xt$tpl_binomial)
  w_dup <- as.character(xt$tpl_binomial[dup])
  n_dup <- length(w_dup)

  ### add column for duplicated species
  xt$duplicated <- dup

  ### Create clean table without duplicated species
  xt_clean <- xt[xt$duplicated == FALSE, ]

  ### Build taxonomic table for species list
  tax <- higher_tax(x = as.character(xt_clean$tpl_binomial))

  ### Warning and messages
  if (n_fail != 0) {
    message(n_fail, " names submitted are not on The Plant List")
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_fail))
    }
  }

  ### Warning and messages
  if (n_spel != 0) {
    message(
      n_spel, " names submitted were corrected automatically!",
      " Make sure they are right."
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_spel))
    }
  }

  ### Warning and messages
  if (n_dup != 0) {
    message(
      n_dup, " names submitted were duplicated after standardization."
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_dup))
    }
  }

  ### Warning and messages
  if (n_miss != 0) {
    message(
      n_miss, " names have `Misapplied` as Taxonomic Statatus!",
      " See `?TPLck()` for details"
    )
    if (verbose == TRUE) {
      message("Check these species manually", paste("\n", w_miss))
    }
  }


  res <- list(
    stz_table_all = xt,
    stz_table_clean = xt_clean,
    which_fail = w_fail,
    which_corrected = w_spel,
    which_duplicated = w_dup,
    taxonomy = tax$taxonomy_full,
    unmatched_genus = tax$unmatched_genus
  )
  return(res)
}

# Function to fuzzy match TPL genus list
fuzzy_genus <- function(x, max.distance, genus_list = NULL) {
  x <- setNames(x, x)
  if (is.null(genus_list)) {
    genus_list <- tpl_genus()
  }
  wg <- lapply(x, function(x) agrep(
      pattern = x, x = genus_list,
      max.distance = max.distance
    ))
  out <- lapply(wg, function(x) genus_list[x])
  return(out)
}
