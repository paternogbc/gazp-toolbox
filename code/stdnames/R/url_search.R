#' Updated genus names
#' 
#' Get the full list of genus names from The Plant List website database.
#'
#' @return A character vector with updated unique genus names from The Plant 
#' List database. 
#' @export
tpl_genus <- function() {
  cli <- crul::HttpClient$new("http://www.theplantlist.org/1.1/browse/-/-/")
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  out <- xml2::xml_text(xml2::xml_find_all(temp, "//ul[@id='nametree']//a"))
  return(unique(out))
}

#' Check genus
#'
#' Check if a genus exist in The Plant List website.
#' @param genus The name of the genus to search on The Plant List.
#'
#' @return A list with the following components:
#' \itemize{
#'   \item{\strong{tpl_genus}} The name of the Genus on The Plant List.
#'   \item{\strong{species_list}} A character vector with the list of species 
#'   from submitted genus name.
#'   }
#' @export
tpl_genus_search <- function(genus) {
  uur <- paste("http://www.theplantlist.org/tpl1.1/search?q=", genus, sep = "")
  cli <- crul::HttpClient$new(uur)
  temp <- cli$get()
  temp$raise_for_status()
  temp <- xml2::read_html(temp$parse("UTF-8"), encoding = "UTF-8")
  all <- xml2::xml_text(xml2::xml_find_all(temp, "//table[@id='tbl-results']//a"))
  
  if (length(all) == 0) {
    #cat(genus, " not found on The Plant List Website \n")
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
  }
  return(out)
}

#' Check if genus occur in TPL
#'
#' @param genus A character vector with genus names to check.
#'
#' @return A data.frame with the provided genus names plus if each genus occurs
#' in TPL.
#' @export
#'
#' @examples
#' library(stdnames)
#' genus <- c("Mimosa", "Aizoom")
#' tpl_genus_check(genus)
tpl_genus_check <- function(genus) {
  x1 <- lapply(genus, tpl_genus_search)
  
  fail <- sapply(seq_len(length(x1)), function(x){
    is.null(x1[[x]]$species_list)
  }
  )
  
  fail
  # Check with updated list
  wf2 <- !genus %in% tpl_genus()
  fail[fail != wf2] <- wf2[fail != wf2]
  
  out <- data.frame(
    genus  = genus,
    on_tpl = !fail,
    stringsAsFactors = FALSE
  )
  return(out)
}

#' Fuzzy matching TPL genus names
#' 
#' Try to match submitted genus name with names from The Plant List using
#' fuzzy maching approach. 
#' 
#' @param x A character vector with genus names to perform match.
#' @param max.distance Maximum distance allowed for a match.
#' @param genus_list The list of unique genus names. If NULL, the updated list
#' of names will be downloaded from The Plant List website with \link{tpl_genus}
#' @param ... Arguments to be passed to \link{agrep}.
#' @return A list with potential matches for the submitted names.
#' @export
fuzzy_genus <- function(x, max.distance = 1, genus_list = NULL, ...) {
  x <- setNames(x, x)
  if (is.null(genus_list)) {
    message("Downloading list of names...")
    genus_list <- stdnames::tpl_genus()
  }
  wg <- lapply(x, function(x) agrep(
    pattern = x, x = genus_list,
    max.distance = max.distance, ...
  ))
  out <- lapply(wg, function(x) genus_list[x])
  names(out) <- names(x)
  return(out)
}

#' Fuzzy matching TPL species names
#' 
#' Try to match submitted species name with names from The Plant List using
#' fuzzy maching approach. 
#' 
#' @param x A character vector with species names to perform match.
#' @param max.distance Maximum distance allowed for a match.
#' @param species_list The list of unique genus names. If NULL, the updated list
#' of names will be downloaded from The Plant List website with \link{tpl_genus}
#' @param ... Arguments to be passed to \link{agrep}.
#' @return A list with potential matches for the submitted names.
#' @export
fuzzy_species <- function(x, max.distance = 1, species_list = NULL, ...) {
  x <- setNames(x, x)
  pn <- parse_names(x)
  
  if (is.null(species_list)) {
    message("Downloading list of names...")
    species_list <- stdnames::tpl_genus_search(pn$genus)$species_list
  }
  wg <- lapply(x, function(x) agrep(
    pattern = x, x = species_list,
    max.distance = max.distance
  ))
  out <- lapply(wg, function(x) species_list[x])
  
  return(out)
}
